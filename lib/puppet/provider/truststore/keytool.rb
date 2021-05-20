require 'puppet_x/certs/provider/keystore'

Puppet::Type.type(:truststore).provide(:keytool) do
  commands :keytool => 'keytool'

  include Puppet_X::Certs::Provider::Keystore

  def store
    resource[:truststore]
  end

  def type
    'truststore'
  end
end
