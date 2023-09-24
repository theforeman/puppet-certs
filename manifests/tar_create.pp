# Define: certs::tar_create
#
# This define creates a tar ball of generated SSL certs
#
# === Parameters
#
# $path::                       The $path of files to tar
#
# $foreman_proxy_fqdn::         FQDN of the foreman proxy
#
define certs::tar_create (
  Stdlib::Absolutepath $path = $title,
  Stdlib::Fqdn $foreman_proxy_fqdn = $certs::foreman_proxy_content::foreman_proxy_fqdn,
) {
  $ca_certificates = 'ssl-build/*.crt'

  $foreman_proxy_certificates = "ssl-build/${foreman_proxy_fqdn}/*.crt"
  $foreman_proxy_keys = "ssl-build/${foreman_proxy_fqdn}/*.key"

  exec { "generate ${path}":
    cwd     => '/root',
    path    => ['/usr/bin', '/bin'],
    command => "tar -caf ${path} ${ca_certificates} ${foreman_proxy_certificates} ${foreman_proxy_keys}",
  }
}
