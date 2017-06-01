# Constains certs specific configurations for candlepin
class certs::candlepin (
  $hostname               = $::certs::node_fqdn,
  $cname                  = $::certs::cname,
  $generate               = $::certs::generate,
  $regenerate             = $::certs::regenerate,
  $deploy                 = $::certs::deploy,
  $ca_cert                = $::certs::ca_cert_stripped,
  $ca_key                 = $::certs::ca_key,
  $pki_dir                = $::certs::pki_dir,
  $keystore               = $::certs::candlepin_keystore,
  $keystore_password_file = $::certs::keystore_password_file,
  $amqp_truststore        = $::certs::candlepin_amqp_truststore,
  $amqp_keystore          = $::certs::candlepin_amqp_keystore,
  $amqp_store_dir         = $::certs::candlepin_amqp_store_dir,
  $tomcat                 = $::certs::tomcat,
  $country                = $::certs::country,
  $state                  = $::certs::state,
  $city                   = $::certs::city,
  $org                    = $::certs::org,
  $org_unit               = $::certs::org_unit,
  $expiration             = $::certs::expiration,
  $default_ca             = $::certs::default_ca,
  $ca_key_password_file   = $::certs::ca_key_password_file,
  $user                   = $::certs::user,
  $group                  = $::certs::group,
  $nss_db_dir             = $::certs::nss_db_dir,
  $qpid_exchange          = $::certs::candlepin_qpid_exchange,
) inherits certs {

  Exec {
    logoutput => 'on_failure',
    path      => ['/bin/', '/usr/bin'],
  }

  $java_client_cert_name = 'java-client'

  cert { $java_client_cert_name:
    ensure        => present,
    hostname      => $hostname,
    cname         => $cname,
    country       => $country,
    state         => $state,
    city          => $city,
    org           => 'candlepin',
    org_unit      => $org_unit,
    expiration    => $expiration,
    ca            => $default_ca,
    generate      => $generate,
    regenerate    => $regenerate,
    deploy        => $deploy,
    password_file => $ca_key_password_file,
  }

  $tomcat_cert_name = "${hostname}-tomcat"
  $tomcat_cert = "${pki_dir}/certs/katello-tomcat.crt"
  $tomcat_key  = "${pki_dir}/private/katello-tomcat.key"

  cert { $tomcat_cert_name:
    ensure        => present,
    hostname      => $hostname,
    cname         => $cname,
    country       => $country,
    state         => $state,
    city          => $city,
    org           => $org,
    org_unit      => $org_unit,
    expiration    => $expiration,
    ca            => $default_ca,
    generate      => $generate,
    regenerate    => $regenerate,
    deploy        => $deploy,
    password_file => $ca_key_password_file,
  }

  $keystore_password = cache_data('foreman_cache_data', $keystore_password_file, random_password(32))
  $password_file = "${pki_dir}/keystore_password-file"
  $client_req = "${pki_dir}/java-client.req"
  $client_cert = "${pki_dir}/certs/${java_client_cert_name}.crt"
  $client_key = "${pki_dir}/private/${java_client_cert_name}.key"

  if $deploy {
    include ::certs::ssltools::nssdb

    Cert[$tomcat_cert_name] ~>
    pubkey { $tomcat_cert:
      key_pair => Cert[$tomcat_cert_name],
    } ~>
    privkey { $tomcat_key:
      key_pair => Cert[$tomcat_cert_name],
    } ~>
    file { $password_file:
      ensure  => file,
      content => $keystore_password,
      owner   => $user,
      group   => $group,
      mode    => '0440',
    } ~>
    exec { 'candlepin-generate-ssl-keystore':
      command => "openssl pkcs12 -export -in ${tomcat_cert} -inkey ${tomcat_key} -out ${keystore} -name tomcat -CAfile ${ca_cert} -caname root -password \"file:${password_file}\" -passin \"file:${ca_key_password_file}\" ",
      creates => $keystore,
    } ~>
    file { "/usr/share/${tomcat}/conf/keystore":
      ensure => link,
      target => $keystore,
      owner  => 'tomcat',
      group  => $group,
    } ->
    certs::keypair { 'candlepin':
      key_pair  => $java_client_cert_name,
      key_file  => $client_key,
      cert_file => $client_cert,
    } ~>
    certs::ssltools::certutil { 'amqp-client':
      nss_db_dir  => $nss_db_dir,
      client_cert => $client_cert,
      refreshonly => true,
      subscribe   => Exec['create-nss-db'],
    } ~>
    file { $amqp_store_dir:
      ensure => directory,
      owner  => 'tomcat',
      group  => $group,
      mode   => '0750',
    } ~>
    exec { 'import CA into Candlepin truststore':
      command => "keytool -import -v -keystore ${amqp_truststore} -storepass ${keystore_password} -alias ${::certs::default_ca_name} -file ${ca_cert} -noprompt",
      creates => $amqp_truststore,
    } ~>
    exec { 'import client certificate into Candlepin keystore':
      # Stupid keytool doesn't allow you to import a keypair.  You can only import a cert.  Hence, we have to
      # create the store as an PKCS12 and convert to JKS.  See http://stackoverflow.com/a/8224863
      command => "openssl pkcs12 -export -name amqp-client -in ${client_cert} -inkey ${client_key} -out /tmp/keystore.p12 -passout file:${password_file} && keytool -importkeystore -destkeystore ${amqp_keystore} -srckeystore /tmp/keystore.p12 -srcstoretype pkcs12 -alias amqp-client -storepass ${keystore_password} -srcstorepass ${keystore_password} -noprompt && rm /tmp/keystore.p12",
      unless  => "keytool -list -keystore ${amqp_keystore} -storepass ${keystore_password} -alias amqp-client",
    } ~>
    file { $amqp_keystore:
      ensure => file,
      owner  => 'tomcat',
      group  => $group,
      mode   => '0640',
    }
  }
}
