# Handles Foreman Proxy cert configuration
class certs::foreman_proxy (
  $hostname            = $::certs::node_fqdn,
  $cname               = $::certs::cname,
  $generate            = $::certs::generate,
  $regenerate          = $::certs::regenerate,
  $deploy              = $::certs::deploy,
  $proxy_cert          = $::certs::params::foreman_proxy_cert,
  $proxy_key           = $::certs::params::foreman_proxy_key,
  $proxy_ca_cert       = $::certs::params::foreman_proxy_ca_cert,
  $foreman_ssl_cert    = $::certs::params::foreman_proxy_foreman_ssl_cert,
  $foreman_ssl_key     = $::certs::params::foreman_proxy_foreman_ssl_key,
  $foreman_ssl_ca_cert = $::certs::params::foreman_proxy_foreman_ssl_ca_cert
) inherits certs::params {

  $proxy_cert_name = "${hostname}-foreman-proxy"
  $foreman_proxy_client_cert_name = "${hostname}-foreman-proxy-client"
  $foreman_proxy_ssl_client_bundle = "${::certs::pki_dir}/private/${foreman_proxy_client_cert_name}-bundle.pem"

  if $::certs::server_cert {
    cert { $proxy_cert_name:
      ensure         => present,
      hostname       => $hostname,
      cname          => $cname,
      generate       => $generate,
      regenerate     => $regenerate,
      deploy         => $deploy,
      custom_pubkey  => $::certs::server_cert,
      custom_privkey => $::certs::server_key,
      custom_req     => $::certs::server_cert_req,
    }
  } else {
    # cert for ssl of foreman-proxy
    cert { $proxy_cert_name:
      hostname      => $hostname,
      cname         => $cname,
      purpose       => 'server',
      country       => $::certs::country,
      state         => $::certs::state,
      city          => $::certs::city,
      org           => 'FOREMAN',
      org_unit      => 'SMART_PROXY',
      expiration    => $::certs::expiration,
      ca            => $::certs::default_ca,
      generate      => $generate,
      regenerate    => $regenerate,
      deploy        => $deploy,
      password_file => $::certs::ca_key_password_file,
    }
  }

  # cert for authentication of foreman_proxy against foreman
  cert { $foreman_proxy_client_cert_name:
    hostname      => $hostname,
    cname         => $cname,
    purpose       => 'client',
    country       => $::certs::country,
    state         => $::certs::state,
    city          => $::certs::city,
    org           => 'FOREMAN',
    org_unit      => 'FOREMAN_PROXY',
    expiration    => $::certs::expiration,
    ca            => $::certs::default_ca,
    generate      => $generate,
    regenerate    => $regenerate,
    deploy        => $deploy,
    password_file => $::certs::ca_key_password_file,
  }

  if $deploy {

    certs::keypair { 'foreman_proxy':
      key_pair   => $proxy_cert_name,
      key_file   => $proxy_key,
      manage_key => true,
      key_owner  => 'foreman-proxy',
      key_mode   => '0400',
      key_group  => $::certs::group,
      cert_file  => $proxy_cert,
    } ->
    pubkey { $proxy_ca_cert:
      key_pair => $::certs::default_ca,
    }

    certs::keypair { 'foreman_proxy_client':
      key_pair   => $foreman_proxy_client_cert_name,
      key_file   => $foreman_ssl_key,
      manage_key => true,
      key_owner  => 'foreman-proxy',
      key_mode   => '0400',
      cert_file  => $foreman_ssl_cert,
    } ->
    pubkey { $foreman_ssl_ca_cert:
      key_pair => $::certs::server_ca,
    } ~>
    key_bundle { $foreman_proxy_ssl_client_bundle:
      key_pair => Cert[$foreman_proxy_client_cert_name],
    } ~>
    file { $foreman_proxy_ssl_client_bundle:
      ensure => file,
      mode   => '0644',
    }

  }
}
