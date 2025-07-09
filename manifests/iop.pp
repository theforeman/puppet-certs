# Contains certs specific configurations for IOP
class certs::iop (
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
  $server_cert_name = "${hostname}-iop-core-gateway-server"
  $client_cert_name = "${hostname}-iop-core-gateway-client"

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

  cert { $client_cert_name:
    ensure        => present,
    purpose       => 'client',
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

  $server_cert = "${certs::ssl_build_dir}/${hostname}/${server_cert_name}.crt"
  $server_key = "${certs::ssl_build_dir}/${hostname}/${server_cert_name}.key"
  $server_ca_cert = $certs::katello_default_ca_cert

  $client_cert = "${certs::ssl_build_dir}/${hostname}/${client_cert_name}.crt"
  $client_key = "${certs::ssl_build_dir}/${hostname}/${client_cert_name}.key"
  $client_ca_cert = $certs::katello_server_ca_cert
}
