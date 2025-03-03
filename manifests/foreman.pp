# Handles Foreman certs configuration
class certs::foreman (
  Optional[Stdlib::Fqdn] $hostname = undef,
  Optional[Array[Stdlib::Fqdn]] $cname = undef,
  Optional[Boolean] $generate = undef,
  Optional[Boolean] $regenerate = undef,
  Optional[Boolean] $deploy = undef,
  Stdlib::Absolutepath $client_cert = '/etc/foreman/client_cert.pem',
  Stdlib::Absolutepath $client_key = '/etc/foreman/client_key.pem',
  Stdlib::Absolutepath $ssl_ca_cert = '/etc/foreman/proxy_ca.pem',
  Optional[String[2,2]] $country = undef,
  Optional[String] $state = undef,
  Optional[String] $city = undef,
  String $org = 'FOREMAN',
  String $org_unit = 'PUPPET',
  Optional[String] $expiration = undef,
  String $owner = 'root',
  String $group = 'foreman',
) {
  include certs

  $real_hostname = pick($hostname, $certs::node_fqdn)
  $client_cert_name = "${real_hostname}-foreman-client"
  $client_dn = "CN=${real_hostname}, OU=${org_unit}, O=${org}, ST=${state}, C=${country}"

  # cert for authentication of puppetmaster against foreman
  cert { $client_cert_name:
    hostname      => $real_hostname,
    cname         => pick($cname, $certs::cname),
    purpose       => 'client',
    country       => pick($country, $certs::country),
    state         => pick($state, $certs::state),
    city          => pick($city, $certs::city),
    org           => $org,
    org_unit      => $org_unit,
    expiration    => pick($expiration, $certs::expiration),
    ca            => $certs::default_ca,
    generate      => pick($generate, $certs::generate),
    regenerate    => pick($regenerate, $certs::regenerate),
    password_file => $certs::ca_key_password_file,
    build_dir     => $certs::ssl_build_dir,
  }

  if pick($deploy, $certs::deploy) {
    certs::keypair { $client_cert_name:
      source_dir => "${certs::ssl_build_dir}/${real_hostname}",
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
      source  => $certs::katello_server_ca_cert,
      owner   => 'root',
      group   => $group,
      mode    => '0440',
      require => File[$certs::katello_server_ca_cert],
    }
  }
}
