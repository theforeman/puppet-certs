require_relative '../../puppet_x/certs/common'

Puppet::Type.newtype(:privkey) do
  desc 'Stores the private key file in a location'

  instance_eval(&PuppetX::Certs::Common::FILE_COMMON_PARAMS)

  # to make the key unprotected by the passphrase
  newparam(:unprotect)
end
