# Pulp Master Certs configuration
class certs::qpid_client (
  $hostname              = $certs::node_fqdn,
  $cname                 = $certs::cname,
  $generate              = $certs::generate,
  $regenerate            = $certs::regenerate,
  $deploy                = $certs::deploy,

  $qpid_client_cert      = $certs::qpid_client_cert,
  $qpid_client_ca_cert   = $certs::qpid_client_ca_cert,

  $country               = $certs::country,
  $state                 = $certs::state,
  $city                  = $certs::city,
  $org_unit              = $certs::org_unit,
  $expiration            = $certs::expiration,
  $default_ca            = $certs::default_ca,
  $ca_key_password_file  = $certs::ca_key_password_file,

  $cert_group            = 'pulp',
) inherits certs {

  $qpid_client_cert_name = "${hostname}-qpid-client-cert"

  cert { $qpid_client_cert_name:
    hostname      => $hostname,
    cname         => $cname,
    common_name   => 'pulp-qpid-client-cert',
    purpose       => client,
    country       => $country,
    state         => $state,
    city          => $city,
    org           => 'PULP',
    org_unit      => $org_unit,
    expiration    => $expiration,
    ca            => $default_ca,
    generate      => $generate,
    regenerate    => $regenerate,
    deploy        => $deploy,
    password_file => $ca_key_password_file,
  }

  if $deploy {

    file { $certs::pulp_pki_dir:
      ensure => directory,
      owner  => 'root',
      group  => $cert_group,
      mode   => '0755',
    }

    file { "${certs::pulp_pki_dir}/qpid":
      ensure => directory,
      owner  => 'root',
      group  => $cert_group,
      mode   => '0640',
    } ~>
    Cert[$qpid_client_cert_name] ~>
    key_bundle { $qpid_client_cert:
      key_pair => Cert[$qpid_client_cert_name],
    } ~>
    file { $qpid_client_cert:
      owner => 'root',
      group => $cert_group,
      mode  => '0640',
    } ~>
    pubkey { $qpid_client_ca_cert:
      key_pair => $default_ca,
    }
  }

}
