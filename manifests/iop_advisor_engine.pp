# Contains certs specific configurations for advisor
class certs::iop_advisor_engine (
  Stdlib::Fqdn $hostname = 'localhost',
  Boolean $generate = $certs::generate,
  Boolean $regenerate = $certs::regenerate,
  Boolean $deploy = $certs::deploy,
  String[2,2] $country = $certs::country,
  String $state = $certs::state,
  String $city = $certs::city,
  String $org = $certs::org,
  String $org_unit = $certs::org_unit,
  String $expiration = $certs::expiration,
  Stdlib::Absolutepath $ca_key_password_file = $certs::ca_key_password_file,
  String $owner = 'root',
  String $group = 'root',
  Stdlib::Filemode $private_key_mode = '0440',
  Stdlib::Filemode $public_key_mode = '0444',
) inherits certs {
  include certs::foreman_proxy

  $server_cert_name = "${hostname}-iop-advisor-server"

  cert { $server_cert_name:
    ensure        => present,
    hostname      => $hostname,
    country       => $country,
    state         => $state,
    city          => $city,
    org           => $org,
    org_unit      => $org_unit,
    expiration    => $expiration,
    ca            => $certs::default_ca,
    generate      => $generate,
    regenerate    => $regenerate,
    password_file => $ca_key_password_file,
    build_dir     => $certs::ssl_build_dir,
  }

  if $deploy {
    require certs::ca

    $cert_directory = '/etc/iop-advisor-engine'

    $server_cert = "${cert_directory}/server.cert"
    $server_key = "${cert_directory}/server.key"
    $server_ca_cert = $certs::ca::server_ca_path

    $client_cert = $certs::foreman_proxy::foreman_ssl_cert
    $client_key = $certs::foreman_proxy::foreman_ssl_key
    $client_ca_cert = $certs::foreman_proxy::foreman_ssl_ca_cert

    file { $cert_directory:
      ensure => directory,
      mode   => '0755',
      owner  => $owner,
      group  => $group,
    }

    certs::keypair { $server_cert_name:
      source_dir => "${certs::ssl_build_dir}/${hostname}",
      key_file   => $server_key,
      key_owner  => $owner,
      key_group  => $group,
      key_mode   => $private_key_mode,
      cert_file  => $server_cert,
      cert_owner => $owner,
      cert_group => $group,
      cert_mode  => $public_key_mode,
      require    => Cert[$server_cert_name],
    }
  }
}
