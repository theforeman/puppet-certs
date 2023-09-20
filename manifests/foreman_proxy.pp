# Handles Foreman Proxy cert configuration
#
# @param $private_key_mode
#   The mode used on private key files (which are owned by root:$group).
#
# @param $public_key_mode
#   The mode used on public key files (which are owned by root:$group).
class certs::foreman_proxy (
  Stdlib::Fqdn $hostname = $certs::node_fqdn,
  Array[Stdlib::Fqdn] $cname = $certs::cname,
  Boolean $generate = $certs::generate,
  Boolean $regenerate = $certs::regenerate,
  Boolean $deploy = $certs::deploy,
  Stdlib::Absolutepath $proxy_cert = '/etc/foreman-proxy/ssl_cert.pem',
  Stdlib::Absolutepath $proxy_key = '/etc/foreman-proxy/ssl_key.pem',
  Stdlib::Absolutepath $proxy_ca_cert = '/etc/foreman-proxy/ssl_ca.pem',
  Stdlib::Absolutepath $foreman_ssl_cert = '/etc/foreman-proxy/foreman_ssl_cert.pem',
  Stdlib::Absolutepath $foreman_ssl_key = '/etc/foreman-proxy/foreman_ssl_key.pem',
  Stdlib::Absolutepath $foreman_ssl_ca_cert = '/etc/foreman-proxy/foreman_ssl_ca.pem',
  Stdlib::Absolutepath $pki_dir = $certs::pki_dir,
  Stdlib::Absolutepath $server_ca_cert = $certs::katello_server_ca_cert,
  Optional[Stdlib::Absolutepath] $server_cert = $certs::server_cert,
  Optional[Stdlib::Absolutepath] $server_key = $certs::server_key,
  Optional[Stdlib::Absolutepath] $server_cert_req = $certs::server_cert_req,
  String[2,2] $country = $certs::country,
  String $state = $certs::state,
  String $city = $certs::city,
  String $expiration = $certs::expiration,
  Type[Ca] $default_ca = $certs::default_ca,
  Stdlib::Absolutepath $default_ca_cert = $certs::katello_default_ca_cert,
  Stdlib::Absolutepath $ca_key_password_file = $certs::ca_key_password_file,
  String $group = 'foreman-proxy',
  String $owner = 'root',
  Stdlib::Filemode $private_key_mode = '0440',
  Stdlib::Filemode $public_key_mode = '0444',
) inherits certs {
  $proxy_cert_name = "${hostname}-foreman-proxy"
  $foreman_proxy_client_cert_name = "${hostname}-foreman-proxy-client"
  $foreman_proxy_ssl_client_bundle = "${pki_dir}/private/${foreman_proxy_client_cert_name}-bundle.pem"

  if $server_cert {
    cert { $proxy_cert_name:
      ensure         => present,
      hostname       => $hostname,
      cname          => $cname,
      generate       => $generate,
      regenerate     => $regenerate,
      deploy         => false,
      custom_pubkey  => $server_cert,
      custom_privkey => $server_key,
      custom_req     => $server_cert_req,
      build_dir      => $certs::ssl_build_dir,
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
      deploy        => false,
      password_file => $ca_key_password_file,
      build_dir     => $certs::ssl_build_dir,
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
    deploy        => false,
    password_file => $ca_key_password_file,
    build_dir     => $certs::ssl_build_dir,
  }

  if $deploy {
    certs::keypair { $proxy_cert_name:
      source_dir => "${certs::ssl_build_dir}/${hostname}",
      key_file   => $proxy_key,
      key_owner  => $owner,
      key_group  => $group,
      key_mode   => $private_key_mode,
      cert_file  => $proxy_cert,
      cert_owner => $owner,
      cert_group => $group,
      cert_mode  => $public_key_mode,
      require    => Cert[$proxy_cert_name],
    }

    file { $proxy_ca_cert:
      ensure  => file,
      source  => $server_ca_cert,
      owner   => $owner,
      group   => $group,
      mode    => '0440',
      require => File[$server_ca_cert],
    }

    certs::keypair { $foreman_proxy_client_cert_name:
      source_dir => "${certs::ssl_build_dir}/${hostname}",
      key_file   => $foreman_ssl_key,
      key_owner  => $owner,
      key_group  => $group,
      key_mode   => $private_key_mode,
      cert_file  => $foreman_ssl_cert,
      cert_owner => $owner,
      cert_group => $group,
      cert_mode  => $public_key_mode,
      require    => Cert[$foreman_proxy_client_cert_name],
    }

    file { $foreman_ssl_ca_cert:
      ensure  => file,
      source  => $server_ca_cert,
      owner   => $owner,
      group   => $group,
      mode    => '0440',
      require => File[$server_ca_cert],
    }

    cert_key_bundle { $foreman_proxy_ssl_client_bundle:
      ensure       => present,
      certificate  => "${certs::ssl_build_dir}/${hostname}/${foreman_proxy_client_cert_name}.crt",
      private_key  => "${certs::ssl_build_dir}/${hostname}/${foreman_proxy_client_cert_name}.key",
      force_pkcs_1 => true,
      owner        => 'root',
      group        => $group,
      mode         => $public_key_mode,
      require      => Cert[$foreman_proxy_client_cert_name],
    }
  }
}
