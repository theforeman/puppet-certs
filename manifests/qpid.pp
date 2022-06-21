# Handles Qpid cert configuration
class certs::qpid (
  Stdlib::Fqdn $hostname = $certs::node_fqdn,
  Array[Stdlib::Fqdn] $cname = $certs::cname,
  Boolean $generate = $certs::generate,
  Boolean $regenerate = $certs::regenerate,
  Boolean $deploy = $certs::deploy,
  String[2,2] $country = $certs::country,
  String $state = $certs::state,
  String $city = $certs::city,
  String $org_unit = $certs::org_unit,
  String $expiration = $certs::expiration,
  $default_ca = $certs::default_ca,
  Stdlib::Absolutepath $ca_key_password_file = $certs::ca_key_password_file,
  Stdlib::Absolutepath $pki_dir = $certs::pki_dir,
  Stdlib::Absolutepath $ca_cert = $certs::ca_cert,
  String $qpidd_group = 'qpidd',
  String $nss_cert_name = 'broker',
) inherits certs {
  $qpid_cert_name = "${hostname}-qpid-broker"

  cert { $qpid_cert_name:
    ensure        => present,
    hostname      => $hostname,
    cname         => concat($cname, 'localhost'),
    country       => $country,
    state         => $state,
    city          => $city,
    org           => 'pulp',
    org_unit      => $org_unit,
    expiration    => $expiration,
    ca            => $default_ca,
    generate      => $generate,
    regenerate    => $regenerate,
    deploy        => false,
    password_file => $ca_key_password_file,
    build_dir     => $certs::ssl_build_dir,
  }

  if $deploy {
    include certs::ssltools::nssdb
    $nss_db_dir = $certs::ssltools::nssdb::nss_db_dir
    $nss_db_password_file = $certs::ssltools::nssdb::nss_db_password_file

    $client_cert            = "${pki_dir}/certs/${qpid_cert_name}.crt"
    $client_key             = "${pki_dir}/private/${qpid_cert_name}.key"

    # Ensure files located at /etc/pki/katello no longer exist
    file { $client_key:
      ensure  => absent,
    }

    file { $client_cert:
      ensure  => absent,
    }

    nssdb_certificate { "${nss_db_dir}:ca":
      ensure        => present,
      certificate   => $ca_cert,
      trustargs     => 'TCu,Cu,Tuw',
      password_file => $nss_db_password_file,
    }

    nssdb_certificate { "${nss_db_dir}:${nss_cert_name}":
      ensure        => present,
      certificate   => "${certs::ssl_build_dir}/${hostname}/${qpid_cert_name}.crt",
      private_key   => "${certs::ssl_build_dir}/${hostname}/${qpid_cert_name}.key",
      trustargs     => ',,',
      password_file => $nss_db_password_file,
    }
  }
}
