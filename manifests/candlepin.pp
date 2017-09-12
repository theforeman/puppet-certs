# Constains certs specific configurations for candlepin
class certs::candlepin (
  $hostname             = $certs::node_fqdn,
  $cname                = $certs::cname,
  $generate             = $certs::generate,
  $regenerate           = $certs::regenerate,
  $deploy               = $certs::deploy,
  $ca_cert              = $certs::candlepin_ca_cert,
  $ca_key               = $certs::candlepin_ca_key,
  $pki_dir              = $certs::pki_dir,
  $keystore             = $certs::candlepin_keystore,
  $keystore_password    = $certs::candlepin_keystore_password,
  $amqp_truststore      = $certs::candlepin_amqp_truststore,
  $amqp_keystore        = $certs::candlepin_amqp_keystore,
  $amqp_store_dir       = $certs::candlepin_amqp_store_dir,
  $country              = $certs::country,
  $state                = $certs::state,
  $city                 = $certs::city,
  $org                  = $certs::org,
  $org_unit             = $certs::org_unit,
  $expiration           = $certs::expiration,
  $default_ca           = $certs::default_ca,
  $default_ca_name      = $certs::default_ca_name,
  $ca_key_password_file = $certs::ca_key_password_file,
  $user                 = $certs::user,
  $group                = $certs::group,
) inherits certs {

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
    } ->
    java_ks { 'tomcat:keystore':
      ensure          => latest,
      target          => $keystore,
      storetype       => 'pkcs12',
      password        => $keystore_password,
      source_password => $keystore_password,
      certificate     => $tomcat_cert,
      private_key     => $tomcat_key,
      chain           => $ca_cert,
    }

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
    } ->
    java_ks { 'candlepin:truststore':
      ensure          => latest,
      name            => $default_ca_name,
      target          => $amqp_truststore,
      storetype       => 'pkcs12',
      password        => $keystore_password,
      source_password => $keystore_password,
      certificate     => $ca_cert,
      trustcacerts    => true,
    } ->
    java_ks { 'amqp-client:keystore':
      ensure          => latest,
      target          => $amqp_keystore,
      storetype       => 'pkcs12',
      password        => $keystore_password,
      source_password => $keystore_password,
      certificate     => $client_cert,
      private_key     => $client_key,
    } ->
    file { $amqp_keystore:
      ensure => file,
      owner  => 'tomcat',
      group  => $group,
      mode   => '0640',
    }
  }
}
