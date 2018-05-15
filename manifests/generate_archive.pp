# == Class: certs::generate_archive
#
# === Parameters:
#
# $server_fqdn::                   FQDN of the Foreman app
#
# $server_cname::                  Additional names of the foreman app
#
# $certs_tar::                     Path to tar file with certs to generate
#
# $foreman_application::           Create certificate bundle for a Foreman node
#
# $foreman_proxy::                 Create certificate bundle for a Foreman Proxy node
#
class certs::generate_archive (
  String $server_fqdn          = undef,
  Array[String] $server_cname  = $certs::params::cname,
  String[1] $certs_tar         = $certs::params::certs_tar,
  Boolean $foreman_application = false,
  Boolean $foreman_proxy       = false,
) inherits certs::params {

  if $server_fqdn == $::fqdn {
    fail('The hostname is the same as the provided hostname for the Foreman app')
  }

  unless $foreman_application or $foreman_proxy {
    fail('What type of certs bundle do you want to generate? Either $foreman_application or $foreman_proxy must be true')
  }

  if $foreman_application {
    $class_list = ['certs::puppet', 'certs::foreman', 'certs::apache', 'certs::qpid_client']
  } elsif $foreman_proxy {
    $class_list = ['certs::puppet', 'certs::foreman', 'certs::foreman_proxy', 'certs::qpid', 'certs::qpid_router', 'certs::apache', 'certs::qpid_client']
  }

  class { $class_list:
    hostname => $server_fqdn,
    cname    => $server_cname,
  }

  certs::tar_create { $certs_tar:
    sub_dir   => $server_fqdn,
    subscribe => Class[$class_list],
  }
}
