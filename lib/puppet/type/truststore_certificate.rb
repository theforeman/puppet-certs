Puppet::Type.newtype(:truststore_certificate) do
  desc 'adds a certificate to a pkcs12 truststore'

  newparam(:name, :namevar => true) do
    desc "The certificate alias used to store inside the truststore"
  end

  newparam(:truststore) do
    desc "Path to the truststore to use or create when importing the certificate"
    isrequired
  end

  newparam(:certificate) do
    desc "Path to the certificate to add to the truststore"
  end

  newparam(:password_file) do
    desc "Path to file containing the truststore password"
    isrequired
  end

  ensurable do
    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end

    def insync?(is)
      @should.each do |should|
        case should
        when :present
          return true if provider.exists?
        when :absent
          return true if is == :absent
        end
      end

      false
    end

    defaultto :present
  end

end
