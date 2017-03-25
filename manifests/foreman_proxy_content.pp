# Prepare the certificates for the node from the parent node
#
# === Parameters:
#
# $parent_fqdn::                    FQDN of the parent node. Does not usually
#                                   need to be set.
#                                   type:Optional[String]
#
# $foreman_proxy_fqdn::             FQDN of the foreman proxy
#                                   type:String
#
# $foreman_proxy_cname::            additional names of the foreman proxy
#                                   type:Array
#
# $certs_tar::                      Path to tar file with certs to generate
#                                   type:Optional[Stdlib::Absolutepath]
#
class certs::foreman_proxy_content (
  $parent_fqdn          = $::fqdn,
  $foreman_proxy_fqdn   = $::certs::params::node_fqdn,
  $foreman_proxy_cname  = $::certs::params::cname,
  $certs_tar            = $::certs::params::certs_tar,
) inherits certs::params {

  # until we support again pushing the cert rpms to the Katello,
  # make sure the certs_tar path is present
  validate_present($certs_tar)
  validate_present($foreman_proxy_fqdn)

  class { '::certs::puppet':        hostname => $foreman_proxy_fqdn, cname => $foreman_proxy_cname }
  class { '::certs::foreman':       hostname => $foreman_proxy_fqdn, cname => $foreman_proxy_cname }
  class { '::certs::foreman_proxy': hostname => $foreman_proxy_fqdn, cname => $foreman_proxy_cname }
  class { '::certs::apache':        hostname => $foreman_proxy_fqdn, cname => $foreman_proxy_cname }
  class { '::certs::qpid':          hostname => $foreman_proxy_fqdn, cname => $foreman_proxy_cname }
  class { '::certs::qpid_router':   hostname => $foreman_proxy_fqdn, cname => $foreman_proxy_cname }
  class { '::certs::qpid_client':   hostname => $foreman_proxy_fqdn, cname => $foreman_proxy_cname }

  if $certs_tar {
    certs::tar_create { $certs_tar:
      subscribe => Class['certs::puppet', 'certs::foreman', 'certs::foreman_proxy', 'certs::qpid', 'certs::qpid_router', 'certs::apache', 'certs::qpid_client'],
    }
  }
}
