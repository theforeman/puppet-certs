# Class for handling Puppet cert configuration
class certs::puppet (
  Stdlib::Fqdn $hostname = $certs::node_fqdn,
  Array[Stdlib::Fqdn] $cname = $certs::cname,
  Boolean $generate = $certs::generate,
  Boolean $regenerate = $certs::regenerate,
  Boolean $deploy = $certs::deploy,
  Stdlib::Absolutepath $client_cert = $certs::puppet_client_cert,
  Stdlib::Absolutepath $client_key = $certs::puppet_client_key,
  Stdlib::Absolutepath $ssl_ca_cert = $certs::puppet_ssl_ca_cert,
  String[2,2] $country = $certs::country,
  String $state = $certs::state,
  String $city = $certs::city,
  String $expiration = $certs::expiration,
  Type[Ca] $default_ca = $certs::default_ca,
  Stdlib::Absolutepath $ca_key_password_file = $certs::ca_key_password_file,
  Stdlib::Absolutepath $server_ca = $certs::katello_server_ca_cert,
  Stdlib::Absolutepath $pki_dir = $certs::pki_dir,
  String $owner = 'root',
  String $group = 'puppet',
) inherits certs {
  $puppet_client_cert_name = "${hostname}-puppet-client"

  # cert for authentication of puppetmaster against foreman
  cert { $puppet_client_cert_name:
    hostname      => $hostname,
    cname         => $cname,
    purpose       => 'client',
    country       => $country,
    state         => $state,
    city          => $city,
    org           => 'FOREMAN',
    org_unit      => 'PUPPET',
    expiration    => $expiration,
    ca            => $default_ca,
    generate      => $generate,
    regenerate    => $regenerate,
    deploy        => false,
    password_file => $ca_key_password_file,
    build_dir     => $certs::ssl_build_dir,
  }

  if $deploy {
    file { "${pki_dir}/puppet":
      ensure => directory,
      owner  => $owner,
      group  => $group,
      mode   => '0750',
    }

    certs::keypair { $puppet_client_cert_name:
      source_dir => "${certs::ssl_build_dir}/${hostname}",
      key_file   => $client_key,
      key_owner  => $owner,
      key_group  => $group,
      key_mode   => '0440',
      cert_file  => $client_cert,
      cert_owner => $owner,
      cert_group => $group,
      cert_mode  => '0440',
      require    => Cert[$puppet_client_cert_name],
    }

    file { $ssl_ca_cert:
      ensure  => file,
      source  => $server_ca,
      owner   => $owner,
      group   => $group,
      mode    => '0440',
      require => File[$server_ca],
    }
  }
}
