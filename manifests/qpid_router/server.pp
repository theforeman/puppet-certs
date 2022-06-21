# Constains certs specific configurations for qpid dispatch router
class certs::qpid_router::server (
  Stdlib::Fqdn $hostname = $certs::node_fqdn,
  Array[Stdlib::Fqdn] $cname = $certs::cname,
  Boolean $generate = $certs::generate,
  Boolean $regenerate = $certs::regenerate,
  Boolean $deploy = $certs::deploy,
  Stdlib::Absolutepath $cert = $certs::qpid_router_server_cert,
  Stdlib::Absolutepath $key = $certs::qpid_router_server_key,
  String $owner = 'qdrouterd',
  String $group = 'root',
  String[2,2] $country = $certs::country,
  String $state = $certs::state,
  String $city = $certs::city,
  String $org_unit = $certs::org_unit,
  String $expiration = $certs::expiration,
  Type[Ca] $default_ca = $certs::default_ca,
  Stdlib::Absolutepath $ca_key_password_file = $certs::ca_key_password_file,
) inherits certs {
  $server_keypair = "${hostname}-qpid-router-server"

  cert { $server_keypair:
    ensure        => present,
    hostname      => $hostname,
    cname         => $cname,
    country       => $country,
    state         => $state,
    city          => $city,
    org           => 'dispatch server',
    org_unit      => $org_unit,
    expiration    => $expiration,
    ca            => $default_ca,
    generate      => $generate,
    regenerate    => $regenerate,
    deploy        => false,
    purpose       => 'server',
    password_file => $ca_key_password_file,
    build_dir     => $certs::ssl_build_dir,
  }

  if $deploy {
    certs::keypair { $server_keypair:
      source_dir => "${certs::ssl_build_dir}/${hostname}",
      key_file   => $key,
      key_owner  => $owner,
      key_group  => $group,
      key_mode   => '0440',
      cert_file  => $cert,
      cert_owner => $owner,
      cert_group => $group,
      cert_mode  => '0640',
      require    => Cert[$server_keypair],
    }
  }
}
