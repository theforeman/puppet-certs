Puppet::Type.newtype(:nssdb_certificate) do
  desc 'adds a certificate to an nssdb'

  ensurable

  def self.title_patterns
    [ [ /(.+):(.+)/m, [ [:nssdb], [:cert_name] ] ] ]
  end

  newparam(:cert_name, :namevar => true) do
    desc "The certificate name used to store inside the nssdb"
  end

  newparam(:nssdb, :namevar => true) do
    desc "Path to the nssdb to use or create when importing the certificate"
    isrequired
  end

  newproperty(:certificate) do
    desc "Path to the certificate to add to the nssdb"

    def fingerprint(file)
      provider.fingerprint(file)
    end

    def should_to_s(newvalue)
      self.class.format_value_for_display(fingerprint(newvalue))
    end

    def insync?(is)
      is == fingerprint(should)
    end
  end

  newparam(:private_key) do
    desc "Path to the private key to add to the nssdb"
  end

  newparam(:trustargs) do
    desc "Certificate trust flags for certificate inside the nssdb. Changing the trustargs on an existing certificate in the NSS database is not supported."
    isrequired
  end

  newparam(:password_file) do
    desc "Path to file containing the nssdb password"
    isrequired
  end

  autorequire(:file) do
    [self[:password_file], self[:nssdb], self[:certificate], self[:private_key]]
  end
end
