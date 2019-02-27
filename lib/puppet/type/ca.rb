require_relative '../../puppet_x/certs/common'

Puppet::Type.newtype(:ca) do
  desc 'Ca for generating signed certs'

  instance_eval(&PuppetX::Certs::Common::CERT_COMMON_PARAMS)

end
