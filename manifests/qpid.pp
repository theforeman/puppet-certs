# Handles Qpid cert configuration
class certs::qpid (
  $hostname             = $certs::node_fqdn,
  $cname                = $certs::cname,
  $generate             = $certs::generate,
  $regenerate           = $certs::regenerate,
  $deploy               = $certs::deploy,
  $country              = $certs::country,
  $state                = $certs::state,
  $city                 = $certs::city,
  $org_unit             = $certs::org_unit,
  $expiration           = $certs::expiration,
  $default_ca           = $certs::default_ca,
  $ca_key_password_file = $certs::ca_key_password_file,
  $pki_dir              = $certs::pki_dir,
  $ca_cert              = $certs::ca_cert,
  $qpidd_group          = 'qpidd',
  $nss_cert_name        = 'broker',
) inherits certs {

  Exec { logoutput => 'on_failure' }

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
    deploy        => $deploy,
    password_file => $ca_key_password_file,
  }

  if $deploy {
    include certs::ssltools::nssdb
    $nss_db_dir = $certs::ssltools::nssdb::nss_db_dir
    $nss_db_password_file = $certs::ssltools::nssdb::nss_db_password_file

    $client_cert            = "${pki_dir}/certs/${qpid_cert_name}.crt"
    $client_key             = "${pki_dir}/private/${qpid_cert_name}.key"
    $pfx_path               = "${pki_dir}/${qpid_cert_name}.pfx"

    certs::keypair { 'qpid':
      key_pair   => Cert[$qpid_cert_name],
      key_file   => $client_key,
      manage_key => true,
      key_owner  => 'root',
      key_group  => $qpidd_group,
      key_mode   => '0440',
      cert_file  => $client_cert,
    } ~>
    # lint:ignore:relative_classname_reference
    Class['::certs::ssltools::nssdb'] ~>
    # lint:endignore
    certs::ssltools::certutil { 'ca':
      nss_db_dir  => $nss_db_dir,
      client_cert => $ca_cert,
      trustargs   => 'TCu,Cu,Tuw',
      refreshonly => true,
      subscribe   => Pubkey[$ca_cert],
    } ~>
    certs::ssltools::certutil { $nss_cert_name:
      nss_db_dir  => $nss_db_dir,
      client_cert => $client_cert,
      refreshonly => true,
      subscribe   => Pubkey[$client_cert],
    } ~>
    exec { 'generate-pfx-for-nss-db':
      command     => "openssl pkcs12 -in ${client_cert} -inkey ${client_key} -export -out '${pfx_path}' -password 'file:${nss_db_password_file}' -name '${nss_cert_name}'",
      path        => '/usr/bin',
      refreshonly => true,
    } ~>
    exec { 'add-private-key-to-nss-db':
      command     => "pk12util -i '${pfx_path}' -d '${nss_db_dir}' -w '${nss_db_password_file}' -k '${nss_db_password_file}'",
      path        => '/usr/bin',
      refreshonly => true,
    }
  }
}
