require File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x/certs/provider/keystore')

Puppet::Type.type(:keystore).provide(:keytool) do
  commands :keytool => 'keytool'

  include PuppetX::Certs::Provider::Keystore
end
