# Prepare the certificates for the node from the parent node
#
# === Parameters:
#
# $foreman_proxy_fqdn::             FQDN of the foreman proxy
#
# $foreman_proxy_cname::            additional names of the foreman proxy
#
# $certs_tar::                      Path to tar file with certs to generate
#
# === Advanced Parameters:
#
# $parent_fqdn::                    FQDN of the parent node. Does not usually
#                                   need to be set.
#
class certs::foreman_proxy_content (
  Stdlib::Fqdn $foreman_proxy_fqdn,
  Stdlib::Absolutepath $certs_tar,
  Stdlib::Fqdn $parent_fqdn = $certs::foreman_proxy_content::params::parent_fqdn,
  Array[Stdlib::Fqdn] $foreman_proxy_cname = $certs::foreman_proxy_content::params::foreman_proxy_cname,
) inherits certs::foreman_proxy_content::params {
  if $foreman_proxy_fqdn == $facts['networking']['fqdn'] {
    fail('The hostname is the same as the provided hostname for the foreman-proxy')
  }

  class { 'certs::puppet':
    deploy   => false,
    hostname => $foreman_proxy_fqdn,
    cname    => $foreman_proxy_cname,
  }

  class { 'certs::foreman_proxy':
    deploy   => false,
    hostname => $foreman_proxy_fqdn,
    cname    => $foreman_proxy_cname,
  }

  class { 'certs::apache':
    deploy   => false,
    hostname => $foreman_proxy_fqdn,
    cname    => $foreman_proxy_cname,
  }

  certs::tar_create { $certs_tar:
    subscribe => Class['certs::puppet', 'certs::foreman_proxy', 'certs::apache'],
  }
}
