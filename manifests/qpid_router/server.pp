# Constains certs specific configurations for qpid dispatch router
class certs::qpid_router::server (
  $hostname               = $certs::node_fqdn,
  $cname                  = $certs::cname,
  $generate               = $certs::generate,
  $regenerate             = $certs::regenerate,
  $deploy                 = $certs::deploy,
  $cert                   = $certs::qpid_router_server_cert,
  $key                    = $certs::qpid_router_server_key,
  $owner                  = 'qdrouterd',
  $group                  = 'root',

  $country               = $certs::country,
  $state                 = $certs::state,
  $city                  = $certs::city,
  $org_unit              = $certs::org_unit,
  $expiration            = $certs::expiration,
  $default_ca            = $certs::default_ca,
  $ca_key_password_file  = $certs::ca_key_password_file,
) inherits certs {
  $server_keypair = "${hostname}-qpid-router-server"

  cert { $server_keypair:
    ensure        => present,
    hostname      => $hostname,
    cname         => $cname,
    country       => $country,
    state         => $state,
    city          => $city,
    org           => 'dispatch server',
    org_unit      => $org_unit,
    expiration    => $expiration,
    ca            => $default_ca,
    generate      => $generate,
    regenerate    => $regenerate,
    deploy        => $deploy,
    purpose       => 'server',
    password_file => $ca_key_password_file,
  }

  if $deploy {
    certs::keypair { 'qpid_dispatch_server':
      key_pair    => Cert[$server_keypair],
      key_file    => $key,
      manage_key  => true,
      key_owner   => $owner,
      key_group   => $group,
      key_mode    => '0640',
      cert_file   => $cert,
      manage_cert => true,
      cert_owner  => $owner,
      cert_group  => $group,
      cert_mode   => '0640',
    }
  }
}
