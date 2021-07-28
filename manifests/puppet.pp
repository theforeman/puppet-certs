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
  $default_ca = $certs::default_ca,
  Stdlib::Absolutepath $ca_key_password_file = $certs::ca_key_password_file,
  $server_ca = $certs::server_ca,
  Stdlib::Absolutepath $pki_dir = $certs::pki_dir,
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
    deploy        => $deploy,
    password_file => $ca_key_password_file,
    build_dir     => $certs::ssl_build_dir,
  }

  if $deploy {
    file { "${pki_dir}/puppet":
      ensure => directory,
      owner  => 'puppet',
      mode   => '0700',
    } ->
    certs::keypair { 'puppet':
      key_pair    => Cert[$puppet_client_cert_name],
      key_file    => $client_key,
      manage_key  => true,
      key_owner   => 'puppet',
      key_mode    => '0400',
      cert_file   => $client_cert,
      manage_cert => true,
      cert_owner  => 'puppet',
      cert_mode   => '0400',
    } ->
    pubkey { $ssl_ca_cert:
      key_pair => $server_ca,
    } ->
    file { $ssl_ca_cert:
      ensure => file,
      owner  => 'puppet',
      mode   => '0400',
    }
  }
}
