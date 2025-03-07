# Handles deploying certificates
#
# === Parameters:
#
# $foreman_proxy::   Deploy certificates needed by Foreman Proxy
#
class certs::deploy (
  Boolean $foreman_proxy = false,
) {
  class { 'certs::foreman_proxy':
    generate => false,
    deploy   => $foreman_proxy,
  }

  if $foreman_proxy {
    Class['certs::foreman_proxy'] ~> Service['foreman-proxy']
  }
}
