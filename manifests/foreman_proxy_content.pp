# Prepare the certificates for the node from the parent node
#
# === Parameters:
#
# $parent_fqdn::                    FQDN of the parent node. Does not usually
#                                   need to be set.
#
# $foreman_proxy_fqdn::             FQDN of the foreman proxy
#
# $foreman_proxy_cname::            additional names of the foreman proxy
#
# $certs_tar::                      Path to tar file with certs to generate
#
class certs::foreman_proxy_content (
  String[1] $parent_fqdn = $::fqdn,
  String $foreman_proxy_fqdn = $::certs::params::node_fqdn,
  Array[String] $foreman_proxy_cname = $::certs::params::cname,
  String[1] $certs_tar = $::certs::params::certs_tar,
) inherits certs::params {

  notify {'DEPRECATION WARNING: certs::foreman_proxy_content has been deprecated, consider using certs::generate_archive with foreman_proxy => true':}

  class { '::certs::generate_archive':
    server_fqdn   => $foreman_proxy_fqdn,
    server_cname  => $foreman_proxy_cname,
    certs_tar     => $certs_tar,
    foreman_proxy => true,
  }
}
