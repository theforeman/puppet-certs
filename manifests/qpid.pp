# Handles Qpid cert configuration
class certs::qpid (
  $hostname   = $::certs::node_fqdn,
  $cname      = $::certs::cname,
  $generate   = $::certs::generate,
  $regenerate = $::certs::regenerate,
  $deploy     = $::certs::deploy,
) {

  Exec { logoutput => 'on_failure' }

  $qpid_cert_name = "${hostname}-qpid-broker"

  cert { $qpid_cert_name:
    ensure        => present,
    hostname      => $hostname,
    cname         => concat($cname, 'localhost'),
    country       => $::certs::country,
    state         => $::certs::state,
    city          => $::certs::city,
    org           => 'pulp',
    org_unit      => $::certs::org_unit,
    expiration    => $::certs::expiration,
    ca            => $::certs::default_ca,
    generate      => $generate,
    regenerate    => $regenerate,
    deploy        => $deploy,
    password_file => $::certs::ca_key_password_file,
  }

  if $deploy {
    include ::certs::ssltools::nssdb
    $nss_db_password_file = $::certs::ssltools::nssdb::nss_db_password_file

    $client_cert            = "${::certs::pki_dir}/certs/${qpid_cert_name}.crt"
    $client_key             = "${::certs::pki_dir}/private/${qpid_cert_name}.key"
    $pfx_path               = "${::certs::pki_dir}/${qpid_cert_name}.pfx"

    certs::keypair { 'qpid':
      key_pair   => $qpid_cert_name,
      key_file   => $client_key,
      manage_key => true,
      key_owner  => 'root',
      key_group  => $::certs::qpidd_group,
      key_mode   => '0440',
      cert_file  => $client_cert,
    } ~>
    Class['::certs::ssltools::nssdb'] ~>
    certs::ssltools::certutil { 'ca':
      nss_db_dir  => $::certs::nss_db_dir,
      client_cert => $::certs::ca_cert,
      trustargs   => 'TCu,Cu,Tuw',
      refreshonly => true,
      subscribe   => Pubkey[$::certs::ca_cert],
    } ~>
    certs::ssltools::certutil { 'broker':
      nss_db_dir  => $::certs::nss_db_dir,
      client_cert => $client_cert,
      refreshonly => true,
      subscribe   => Pubkey[$client_cert],
    } ~>
    exec { 'generate-pfx-for-nss-db':
      command     => "openssl pkcs12 -in ${client_cert} -inkey ${client_key} -export -out '${pfx_path}' -password 'file:${nss_db_password_file}'",
      path        => '/usr/bin',
      refreshonly => true,
    } ~>
    exec { 'add-private-key-to-nss-db':
      command     => "pk12util -i '${pfx_path}' -d '${::certs::nss_db_dir}' -w '${nss_db_password_file}' -k '${nss_db_password_file}'",
      path        => '/usr/bin',
      refreshonly => true,
    }
  }
}
