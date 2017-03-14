# Class for handling Puppet cert configuration
class certs::puppet (
  $hostname             = $::certs::node_fqdn,
  $cname                = $::certs::cname,
  $generate             = $::certs::generate,
  $regenerate           = $::certs::regenerate,
  $deploy               = $::certs::deploy,

  $client_cert          = $::certs::puppet_client_cert,
  $client_key           = $::certs::puppet_client_key,
  $ssl_ca_cert          = $::certs::puppet_ssl_ca_cert,

  $country              = $::certs::country,
  $state                = $::certs::state,
  $city                 = $::certs::city,
  $expiration           = $::certs::expiration,
  $default_ca           = $::certs::default_ca,
  $ca_key_password_file = $::certs::ca_key_password_file,
  $server_ca            = $::certs::server_ca,

  $pki_dir              = $::certs::pki_dir,
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
  }

  if $deploy {
    file { "${pki_dir}/puppet":
      ensure  => directory,
      owner   => 'puppet',
      mode    => '0700',
      require => Class['puppet::server::install'],
    } ->
    certs::keypair { 'puppet':
      key_pair    => $puppet_client_cert_name,
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
