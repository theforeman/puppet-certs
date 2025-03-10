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
  Stdlib::Absolutepath $ca_key_password_file = $certs::ca_key_password_file,
  Stdlib::Absolutepath $server_ca = $certs::katello_server_ca_cert,
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
    ca            => $certs::default_ca,
    generate      => $generate,
    regenerate    => $regenerate,
    password_file => $ca_key_password_file,
    build_dir     => $certs::ssl_build_dir,
  }

  if $deploy {
    certs::keypair { $client_cert_name:
      source_dir => "${certs::ssl_build_dir}/${hostname}",
      key_file   => $client_key,
      key_owner  => $owner,
      key_group  => $group,
      key_mode   => '0440',
      cert_file  => $client_cert,
      cert_owner => $owner,
      cert_group => $group,
      cert_mode  => '0440',
      require    => Cert[$client_cert_name],
    }

    file { $ssl_ca_cert:
      ensure  => file,
      source  => $certs::ca::ca_bundle_path,
      owner   => 'root',
      group   => $group,
      mode    => '0440',
      require => Concat[$certs::ca::ca_bundle_path],
    }
  }
}
