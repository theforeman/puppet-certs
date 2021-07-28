# Handles Foreman certs configuration
class certs::foreman (
  Stdlib::Fqdn $hostname = $certs::node_fqdn,
  Array[Stdlib::Fqdn] $cname = $certs::cname,
  Boolean $generate = $certs::generate,
  Boolean $regenerate = $certs::regenerate,
  Boolean $deploy = $certs::deploy,
  Stdlib::Absolutepath $client_cert = '/etc/foreman/client_cert.pem',
  Stdlib::Absolutepath $client_key = '/etc/foreman/client_key.pem',
  Stdlib::Absolutepath $ssl_ca_cert = '/etc/foreman/proxy_ca.pem',
  String[2,2] $country = $certs::country,
  String $state = $certs::state,
  String $city = $certs::city,
  String $org = 'FOREMAN',
  String $org_unit = 'PUPPET',
  String $expiration = $certs::expiration,
  $default_ca = $certs::default_ca,
  Stdlib::Absolutepath $ca_key_password_file = $certs::ca_key_password_file,
  $server_ca = $certs::server_ca,
  String $owner = 'root',
  String $group = 'foreman',
) inherits certs {

  $client_cert_name = "${hostname}-foreman-client"
  $client_dn = "CN=${hostname}, OU=${org_unit}, O=${org}, ST=${state}, C=${country}"

  # cert for authentication of puppetmaster against foreman
  cert { $client_cert_name:
    hostname      => $hostname,
    cname         => $cname,
    purpose       => 'client',
    country       => $country,
    state         => $state,
    city          => $city,
    org           => $org,
    org_unit      => $org_unit,
    expiration    => $expiration,
    ca            => $default_ca,
    generate      => $generate,
    regenerate    => $regenerate,
    deploy        => $deploy,
    password_file => $ca_key_password_file,
    build_dir     => $certs::ssl_build_dir,
  }

  if $deploy {
    certs::keypair { 'foreman':
      key_pair    => Cert[$client_cert_name],
      key_file    => $client_key,
      manage_key  => true,
      key_owner   => $owner,
      key_group   => $group,
      key_mode    => '0440',
      cert_file   => $client_cert,
      manage_cert => true,
      cert_owner  => $owner,
      cert_group  => $group,
      cert_mode   => '440',
    } ->
    pubkey { $ssl_ca_cert:
      key_pair => $server_ca,
    }

    file { $ssl_ca_cert:
      ensure  => file,
      owner   => $owner,
      group   => $group,
      mode    => '0440',
      require => Pubkey[$ssl_ca_cert],
    }
  }
}
