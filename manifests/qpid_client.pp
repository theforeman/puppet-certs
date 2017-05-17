# Pulp Master Certs configuration
class certs::qpid_client (
  $hostname              = $::certs::node_fqdn,
  $cname                 = $::certs::cname,
  $generate              = $::certs::generate,
  $regenerate            = $::certs::regenerate,
  $deploy                = $::certs::deploy,

  $messaging_client_cert = $::certs::messaging_client_cert,

  $country               = $::certs::country,
  $state                 = $::certs::state,
  $city                  = $::certs::city,
  $org_unit              = $::certs::org_unit,
  $expiration            = $::certs::expiration,
  $default_ca            = $::certs::default_ca,
  $ca_key_password_file  = $::certs::ca_key_password_file,
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

    Cert[$qpid_client_cert_name] ~>
    key_bundle { $messaging_client_cert:
      key_pair => Cert[$qpid_client_cert_name],
    } ~>
    file { $messaging_client_cert:
      owner => 'apache',
      group => 'apache',
      mode  => '0640',
    }

  }

}
