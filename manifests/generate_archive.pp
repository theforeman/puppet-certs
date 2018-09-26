# == Class: certs::generate_archive
#
# === Parameters:
#
# $hostnames::   The hostname for which to generate certificates
#
# $cnames::      Additional names on the certificate
#
# $certs_tar::   Path to tar file with certs to generate
#
# $roles::       The roles for which certificates should be generated. The
#                all-server and all-proxy are presets for the relative roles.
#
class certs::generate_archive (
  Stdlib::Fqdn $hostname,
  String[1] $certs_tar,
  Certs::Role $role,
  Array[Stdlib::Fqdn] $cnames = [],
) {

  if $hostname == $facts['fqdn'] {
    fail('The hostname is the same as the provided hostname for the Foreman app')
  }

  $classes = $role ? {
    'all-server' => ['apache', 'foreman', 'puppet', 'qpid_client'],
    'all-proxy'  => ['apache', 'foreman', 'foreman_proxy', 'puppet', 'qpid', 'qpid_client', 'qpid_router'],
    default      => $role,
  }

  class { prefix($classes, 'certs::'):
    hostname => $hostname,
    cname    => $cnames,
  } ~>
  certs::tar_create { $certs_tar:
    sub_dir => $hostname,
  }
}
