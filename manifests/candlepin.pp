# Constains certs specific configurations for candlepin
class certs::candlepin (
  $hostname               = $certs::node_fqdn,
  $cname                  = $certs::cname,
  $generate               = $certs::generate,
  $regenerate             = $certs::regenerate,
  $deploy                 = $certs::deploy,
  $ca_cert                = $certs::candlepin_ca_cert,
  $ca_key                 = $certs::candlepin_ca_key,
  $pki_dir                = $certs::pki_dir,
  $keystore               = $certs::candlepin_keystore,
  $keystore_password_file = $certs::keystore_password_file,
  $amqp_truststore        = $certs::candlepin_amqp_truststore,
  $amqp_keystore          = $certs::candlepin_amqp_keystore,
  $amqp_store_dir         = $certs::candlepin_amqp_store_dir,
  $country                = $certs::country,
  $state                  = $certs::state,
  $city                   = $certs::city,
  $org                    = $certs::org,
  $org_unit               = $certs::org_unit,
  $expiration             = $certs::expiration,
  $default_ca             = $certs::default_ca,
  $ca_key_password_file   = $certs::ca_key_password_file,
  $user                   = $certs::user,
  $group                  = $certs::group,
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

  $keystore_password = extlib::cache_data('foreman_cache_data', $keystore_password_file, extlib::random_password(32))
  $password_file = "${pki_dir}/keystore_password-file"
  $client_req = "${pki_dir}/java-client.req"
  $client_cert = "${pki_dir}/certs/${java_client_cert_name}.crt"
  $client_key = "${pki_dir}/private/${java_client_cert_name}.key"
  $alias = 'candlepin-ca'

  if $deploy {
    certs::keypair { 'candlepin-ca':
      manage_cert   => true,
      manage_key    => true,
      key_pair      => $default_ca,
      key_file      => $ca_key,
      cert_file     => $ca_cert,
      cert_owner    => 'tomcat',
      cert_group    => 'tomcat',
      key_owner     => 'tomcat',
      key_group     => 'tomcat',
      key_mode      => '0440',
      cert_mode     => '0640',
      unprotect     => true,
      strip         => true,
      password_file => $ca_key_password_file,
    } ~>
    certs::keypair { 'tomcat':
      key_pair  => Cert[$tomcat_cert_name],
      key_file  => $tomcat_key,
      cert_file => $tomcat_cert,
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
      unless  => "keytool -list -keystore ${keystore} -storepass ${keystore_password} -alias tomcat | grep $(openssl x509 -noout -fingerprint -in ${tomcat_cert} | cut -d '=' -f 2)",
    } ~>
    file { $keystore:
      ensure => file,
      owner  => 'tomcat',
      group  => $group,
      mode   => '0640',
    } ~>
    certs::keypair { 'candlepin':
      key_pair  => Cert[$java_client_cert_name],
      key_file  => $client_key,
      cert_file => $client_cert,
    } ~>
    file { $amqp_store_dir:
      ensure => directory,
      owner  => 'tomcat',
      group  => $group,
      mode   => '0750',
    } ~>
    exec { 'import CA into Candlepin truststore':
      command => "keytool -import -trustcacerts -v -keystore ${keystore} -storepass ${keystore_password} -alias ${alias} -file ${ca_cert} -noprompt",
      unless  => "keytool -list -keystore ${keystore} -storepass ${keystore_password} -alias ${alias}",
    } ~>
    exec { 'import CA into Candlepin AMQP truststore':
      command => "keytool -import -v -keystore ${amqp_truststore} -storepass ${keystore_password} -alias ${alias} -file ${ca_cert} -trustcacerts -noprompt",
      unless  => "keytool -list -keystore ${amqp_truststore} -storepass ${keystore_password} -alias ${alias}",
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
