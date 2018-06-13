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
# $generate_repomd_gpg::            Whether a yum repo metadata GPG key should be generated
#
# === Advanced Parameters:
#
# $parent_fqdn::                    FQDN of the parent node. Does not usually
#                                   need to be set.
#
class certs::foreman_proxy_content (
  Stdlib::Fqdn $foreman_proxy_fqdn,
  Stdlib::Absolutepath $certs_tar,
  Boolean $generate_repomd_gpg = true,
  Stdlib::Fqdn $parent_fqdn = $certs::foreman_proxy_content::params::parent_fqdn,
  Array[Stdlib::Fqdn] $foreman_proxy_cname = $certs::foreman_proxy_content::params::foreman_proxy_cname,
) inherits certs::foreman_proxy_content::params {

  if $foreman_proxy_fqdn == $facts['fqdn'] {
    fail('The hostname is the same as the provided hostname for the foreman-proxy')
  }

  class { '::certs::puppet':        hostname => $foreman_proxy_fqdn, cname => $foreman_proxy_cname }
  class { '::certs::foreman':       hostname => $foreman_proxy_fqdn, cname => $foreman_proxy_cname }
  class { '::certs::foreman_proxy': hostname => $foreman_proxy_fqdn, cname => $foreman_proxy_cname }
  class { '::certs::apache':        hostname => $foreman_proxy_fqdn, cname => $foreman_proxy_cname }
  class { '::certs::qpid':          hostname => $foreman_proxy_fqdn, cname => $foreman_proxy_cname }
  class { '::certs::qpid_router':   hostname => $foreman_proxy_fqdn, cname => $foreman_proxy_cname }
  class { '::certs::qpid_client':   hostname => $foreman_proxy_fqdn, cname => $foreman_proxy_cname }

  if !$generate_repomd_gpg {
    $class_list = ['certs::puppet', 'certs::foreman', 'certs::foreman_proxy', 'certs::qpid', 'certs::qpid_router', 'certs::apache', 'certs::qpid_client']
  } else {
    class { '::certs::repomd_gpg': hostname => $foreman_proxy_fqdn }
    $class_list = ['certs::puppet', 'certs::foreman', 'certs::foreman_proxy', 'certs::qpid', 'certs::qpid_router', 'certs::apache', 'certs::qpid_client', 'certs::repomd_gpg']
  }
  certs::tar_create { $certs_tar:
    subscribe => Class[$class_list],
  }
}
