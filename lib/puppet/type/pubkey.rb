require_relative '../../puppet_x/certs/common'

Puppet::Type.newtype(:pubkey) do
  desc 'Stores the public key file in a location'

  instance_eval(&PuppetX::Certs::Common::FILE_COMMON_PARAMS)

  # will generate a key with the certificate information stripped
  newparam(:strip)
end
