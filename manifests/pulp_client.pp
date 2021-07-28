# Pulp Client Certs
class certs::pulp_client (
  Stdlib::Fqdn $hostname = $certs::node_fqdn,
  Array[Stdlib::Fqdn] $cname = $certs::cname,
  Boolean $generate = $certs::generate,
  Boolean $regenerate = $certs::regenerate,
  Boolean $deploy = $certs::deploy,
  String $common_name = 'admin',
  Stdlib::Absolutepath $pki_dir = $certs::pki_dir,
  Stdlib::Absolutepath $ca_cert = $certs::ca_cert,
  String[2,2] $country = $certs::country,
  String $state = $certs::state,
  String $city = $certs::city,
  String $expiration = $certs::expiration,
  $default_ca = $certs::default_ca,
  Stdlib::Absolutepath $ca_key_password_file = $certs::ca_key_password_file,
  String $group = $certs::group,
) inherits certs {

  $client_cert_name = 'pulp-client'
  $client_cert      = "${pki_dir}/certs/${client_cert_name}.crt"
  $client_key       = "${pki_dir}/private/${client_cert_name}.key"
  $ssl_ca_cert      = $ca_cert

  cert { $client_cert_name:
    hostname      => $hostname,
    cname         => $cname,
    common_name   => $common_name,
    purpose       => client,
    country       => $certs::country,
    state         => $certs::state,
    city          => $certs::city,
    org           => 'PULP',
    org_unit      => 'NODES',
    expiration    => $expiration,
    ca            => $default_ca,
    generate      => $generate,
    regenerate    => $regenerate,
    deploy        => $deploy,
    password_file => $ca_key_password_file,
    build_dir     => $certs::ssl_build_dir,
  }

  if $deploy {
    certs::keypair { 'pulp_client':
      key_pair   => Cert[$client_cert_name],
      key_file   => $client_key,
      manage_key => true,
      key_group  => $group,
      key_owner  => 'root',
      key_mode   => '0440',
      cert_file  => $client_cert,
    }
  }
}
