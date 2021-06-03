# Certs configurations for Apache
class certs::apache (
  Boolean $deploy = $certs::deploy,
  Stdlib::Absolutepath $pki_dir = $certs::pki_dir,
  Optional[Stdlib::Absolutepath] $server_cert = $certs::server_cert,
  Optional[Stdlib::Absolutepath] $server_key = $certs::server_key,
  String[1] $group = 'root',
) inherits certs {
  $apache_cert = "${pki_dir}/certs/katello-apache.crt"
  $apache_key  = "${pki_dir}/private/katello-apache.key"

  if $server_cert {
    $cert_source = $server_cert
    $key_source = $server_key
    $require = undef

    $apache_ca_cert = $certs::katello_server_ca_cert
  } else {
    include certs::certificate
    $cert_source = $certs::certificate::certificate_file
    $key_source = $certs::certificate::private_key_file
    $require = Class['certs::certificate']

    $apache_ca_cert = $certs::certificate::ca_file
  }

  if $deploy {
    certs::key_pair { 'apache':
      key_destination  => $apache_key,
      key_source       => $key_source,
      key_group        => $group,
      cert_destination => $apache_cert,
      cert_source      => $cert_source,
      require          => $require,
    }
  }
}
