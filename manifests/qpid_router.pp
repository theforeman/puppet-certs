# Constains certs specific configurations for qpid dispatch router
class certs::qpid_router(
  $hostname               = $::certs::node_fqdn,
  $cname                  = $::certs::cname,
  $generate               = $::certs::generate,
  $regenerate             = $::certs::regenerate,
  $deploy                 = $::certs::deploy,
  $server_cert            = $::certs::qpid_router_server_cert,
  $client_cert            = $::certs::qpid_router_client_cert,
  $server_key             = $::certs::qpid_router_server_key,
  $client_key             = $::certs::qpid_router_client_key,
  $owner                  = $::certs::qpid_router_owner,
  $group                  = $::certs::qpid_router_group,
) inherits certs::params {

  $server_keypair = "${hostname}-qpid-router-server"
  $client_keypair = "${hostname}-qpid-router-client"

  cert { $server_keypair:
    ensure        => present,
    hostname      => $hostname,
    cname         => $cname,
    country       => $::certs::country,
    state         => $::certs::state,
    city          => $::certs::city,
    org           => 'dispatch server',
    org_unit      => $::certs::org_unit,
    expiration    => $::certs::expiration,
    ca            => $::certs::default_ca,
    generate      => $generate,
    regenerate    => $regenerate,
    deploy        => $deploy,
    purpose       => 'server',
    password_file => $::certs::ca_key_password_file,
  }

  cert { $client_keypair:
    ensure        => present,
    hostname      => $hostname,
    cname         => $cname,
    country       => $::certs::country,
    state         => $::certs::state,
    city          => $::certs::city,
    org           => 'dispatch client',
    org_unit      => $::certs::org_unit,
    expiration    => $::certs::expiration,
    ca            => $::certs::default_ca,
    generate      => $generate,
    regenerate    => $regenerate,
    deploy        => $deploy,
    purpose       => 'client',
    password_file => $::certs::ca_key_password_file,
  }

  if $deploy {
    certs::keypair { 'qpid_router_server':
      key_pair    => $server_keypair,
      key_file    => $server_key,
      manage_key  => true,
      key_owner   => $owner,
      key_group   => $group,
      key_mode    => '0640',
      cert_file   => $server_cert,
      manage_cert => true,
      cert_owner  => $owner,
      cert_group  => $group,
      cert_mode   => '0640',
    }

    certs::keypair { 'qpid_router_client':
      key_pair    => $client_keypair,
      key_file    => $client_key,
      manage_key  => true,
      key_owner   => $owner,
      key_group   => $group,
      key_mode    => '0640',
      cert_file   => $client_cert,
      manage_cert => true,
      cert_owner  => $owner,
      cert_group  => $group,
      cert_mode   => '0640',
    }
  }
}
