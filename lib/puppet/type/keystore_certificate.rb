Puppet::Type.newtype(:keystore_certificate) do
  desc 'adds a certificate and private key to a PKCS12 keystore'

  ensurable

  def self.title_patterns
    [
      [
        /(.+):(.+)/,
        [[:keystore], [:alias]]
      ],
      [
        /(.+)/,
        [[:alias]],
      ],
    ]
  end

  newparam(:alias, :namevar => true) do
    desc "The certificate alias used to store inside the keystore"
  end

  newparam(:keystore, :namevar => true) do
    desc "Path to the keystore to use when importing the certificate"
    isrequired
  end

  newproperty(:certificate) do
    desc "Path to the file containing the certificate to add to the keystore"

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
    desc "Path to file containing the private key"
    isrequired
  end

  newparam(:ca) do
    desc "Path to the file containing the CA certificate"
  end

  newparam(:password_file) do
    desc "Path to file containing the keystore password"
    isrequired
  end

  autorequire(:file) do
    [
      self[:password_file],
      self[:certificate],
      self[:private_key],
      self[:ca],
      self[:keystore]
    ]
  end
end
