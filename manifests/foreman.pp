# Handles Foreman certs configuration
class certs::foreman (
  $hostname              = $certs::node_fqdn,
  $cname                 = $certs::cname,
  $generate              = $certs::generate,
  $regenerate            = $certs::regenerate,
  $deploy                = $certs::deploy,
  $client_cert           = '/etc/foreman/client_cert.pem',
  $client_key            = '/etc/foreman/client_key.pem',
  $ssl_ca_cert           = '/etc/foreman/proxy_ca.pem',
  $country               = $certs::country,
  $state                 = $certs::state,
  $city                  = $certs::city,
  $org                   = 'FOREMAN',
  $org_unit              = 'PUPPET',
  $expiration            = $certs::expiration,
  $default_ca            = $certs::default_ca,
  $ca_key_password_file  = $certs::ca_key_password_file,
  $server_ca             = $certs::server_ca,
  $owner                 = 'root',
  $group                 = 'foreman',
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
  }
}
