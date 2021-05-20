require 'puppet_x/certs/provider/keystore'

Puppet::Type.type(:keystore).provide(:keytool) do
  commands :keytool => 'keytool'

  include Puppet_X::Certs::Provider::Keystore
end
