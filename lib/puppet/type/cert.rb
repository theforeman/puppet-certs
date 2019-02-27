require_relative '../../puppet_x/certs/common'

Puppet::Type.newtype(:cert) do
  desc 'ca signed cert'

  instance_eval(&PuppetX::Certs::Common::CERT_COMMON_PARAMS)

  newparam(:hostname)

  newparam(:purpose) do
    defaultto 'server'
  end
end
