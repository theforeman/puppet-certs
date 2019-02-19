# Handles Foreman Proxy cert configuration
class certs::foreman_proxy (
  $hostname             = $certs::node_fqdn,
  $cname                = $certs::cname,
  $generate             = $certs::generate,
  $regenerate           = $certs::regenerate,
  $deploy               = $certs::deploy,
  $proxy_cert           = $certs::params::foreman_proxy_cert,
  $proxy_key            = $certs::params::foreman_proxy_key,
  $proxy_ca_cert        = $certs::params::foreman_proxy_ca_cert,
  $foreman_ssl_cert     = $certs::params::foreman_proxy_foreman_ssl_cert,
  $foreman_ssl_key      = $certs::params::foreman_proxy_foreman_ssl_key,
  $foreman_ssl_ca_cert  = $certs::params::foreman_proxy_foreman_ssl_ca_cert,
  $pki_dir              = $certs::pki_dir,
  $server_ca            = $certs::server_ca,
  $server_cert          = $certs::server_cert,
  $server_key           = $certs::server_key,
  $server_cert_req      = $certs::server_cert_req,
  $country              = $certs::country,
  $state                = $certs::state,
  $city                 = $certs::city,
  $expiration           = $certs::expiration,
  $default_ca           = $certs::default_ca,
  $ca_key_password_file = $certs::ca_key_password_file,
  $group                = $certs::group,
) inherits certs {

  $proxy_cert_name = "${hostname}-foreman-proxy"
  $foreman_proxy_client_cert_name = "${hostname}-foreman-proxy-client"

  if $server_cert {
    cert { $proxy_cert_name:
      ensure         => present,
      hostname       => $hostname,
      cname          => $cname,
      generate       => $generate,
      regenerate     => $regenerate,
      deploy         => $deploy,
      custom_pubkey  => $server_cert,
      custom_privkey => $server_key,
      custom_req     => $server_cert_req,
    }
  } else {
    # cert for ssl of foreman-proxy
    cert { $proxy_cert_name:
      hostname      => $hostname,
      cname         => $cname,
      purpose       => 'server',
      country       => $country,
      state         => $state,
      city          => $city,
      org           => 'FOREMAN',
      org_unit      => 'SMART_PROXY',
      expiration    => $expiration,
      ca            => $default_ca,
      generate      => $generate,
      regenerate    => $regenerate,
      deploy        => $deploy,
      password_file => $ca_key_password_file,
    }
  }

  # cert for authentication of foreman_proxy against foreman
  cert { $foreman_proxy_client_cert_name:
    hostname      => $hostname,
    cname         => $cname,
    purpose       => 'client',
    country       => $country,
    state         => $state,
    city          => $city,
    org           => 'FOREMAN',
    org_unit      => 'FOREMAN_PROXY',
    expiration    => $expiration,
    ca            => $default_ca,
    generate      => $generate,
    regenerate    => $regenerate,
    deploy        => $deploy,
    password_file => $ca_key_password_file,
  }

  if $deploy {

    certs::keypair { 'foreman_proxy':
      key_pair   => Cert[$proxy_cert_name],
      key_file   => $proxy_key,
      manage_key => true,
      key_owner  => 'foreman-proxy',
      key_mode   => '0400',
      key_group  => $group,
      cert_file  => $proxy_cert,
    } ->
    pubkey { $proxy_ca_cert:
      key_pair => $default_ca,
    }

    certs::keypair { 'foreman_proxy_client':
      key_pair   => Cert[$foreman_proxy_client_cert_name],
      key_file   => $foreman_ssl_key,
      manage_key => true,
      key_owner  => 'foreman-proxy',
      key_mode   => '0400',
      cert_file  => $foreman_ssl_cert,
    } ->
    pubkey { $foreman_ssl_ca_cert:
      key_pair => $server_ca,
    }
  }
}
