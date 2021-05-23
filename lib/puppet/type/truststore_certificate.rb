Puppet::Type.newtype(:truststore_certificate) do
  desc 'adds a certificate to a pkcs12 truststore'

  ensurable

  def self.title_patterns
    [[%r{(.+):(.+)}m, [[:truststore], [:alias]]]]
  end

  newparam(:alias, namevar: true) do
    desc 'The certificate alias used to store inside the truststore'
  end

  newparam(:truststore, namevar: true) do
    desc 'Path to the truststore to use or create when importing the certificate'
    isrequired
  end

  newproperty(:certificate) do
    desc 'Path to the certificate to add to the truststore'

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

  newparam(:password_file) do
    desc 'Path to file containing the truststore password'
    isrequired
  end

  autorequire(:file) do
    [self[:password_file], File.dirname(self[:truststore]), self[:certificate]]
  end

  autonotify(:file) do
    [self[:truststore]]
  end
end
