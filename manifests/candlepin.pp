# Constains certs specific configurations for candlepin
class certs::candlepin (
    $hostname = $::certs::node_fqdn,
    $generate = $::certs::generate,
    $regenerate = $::certs::regenerate,
    $deploy   = $::certs::deploy,
    $ca       = $::certs::default_ca,
    $storage  = '/etc/candlepin/certs',
    $ca_cert  = '/etc/candlepin/certs/candlepin-ca.crt',
    $ca_key  = '/etc/candlepin/certs/candlepin-ca.key',
    $pki_dir = '/etc/pki/katello',
    $keystore = '/etc/pki/katello/keystore',
    $keystore_password_file = undef,
    $keystore_password = undef,
    $candlepin_certs_dir = $certs::params::candlepin_certs_dir
  ) {

  Exec { logoutput => 'on_failure' }

  if $deploy {
    file { $keystore_password_file:
      ensure  => file,
      content => $keystore_password,
      mode    => '0644',
      owner   => 'tomcat',
      group   => $::certs::user_groups,
      replace => false;
    } ~>
    file { $pki_dir:
      ensure => directory,
      owner  => 'root',
      group  => $::certs::user_groups,
      mode   => '0750',
    } ~>
    pubkey { $ca_cert:
      cert => $ca,
    } ~>
    file { $ca_cert:
      owner   => 'root',
      group   => $::certs::user_groups,
      mode    => '0644';
    } ~>
    # TODO: it would be probably a bit better to not unprotect it here and
    # make candlepin and openssl pkcs12 command to use the passphrase-file instead.
    # On the other hand, technically there is not big difference between having
    # the key unprotected or storing the passphrase-file: in both cases, getting
    # the file means corrupting the certificate
    privkey { $ca_key:
      cert      => $ca,
      unprotect => true;
    } ~>
    file { $ca_key:
      owner   => 'root',
      group   => $::certs::user_groups,
      mode    => '0640';
    } ~>
    exec { 'generate-ssl-keystore':
      command   => "openssl pkcs12 -export -in ${ca_cert} -inkey ${ca_key} -out ${keystore} -name tomcat -CAfile ${ca_cert} -caname root -password \"file:${keystore_password_file}\"",
      path      => '/bin:/usr/bin',
      creates   => $keystore;
    } ~>

    file { "/usr/share/${candlepin::tomcat}/conf/keystore":
      ensure  => link,
      target  => $keystore;
    } ~>
    exec { 'add-candlepin-cert-to-nss-db':
      command     => "certutil -A -d '${::certs::nss_db_dir}' -n 'ca' -t 'TCu,Cu,Tuw' -a -i '${ca_cert}'",
      path        => '/usr/bin',
      subscribe   => Exec['create-nss-db'],
      refreshonly => true,
    }

  }
}
