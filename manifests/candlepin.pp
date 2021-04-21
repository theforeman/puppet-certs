# Constains certs specific configurations for candlepin
class certs::candlepin (
  $hostname                 = $certs::node_fqdn,
  $cname                    = $certs::cname,
  $generate                 = $certs::generate,
  $regenerate               = $certs::regenerate,
  $deploy                   = $certs::deploy,
  $ca_cert                  = $certs::candlepin_ca_cert,
  $ca_key                   = $certs::candlepin_ca_key,
  $pki_dir                  = $certs::pki_dir,
  $keystore                 = $certs::candlepin_keystore,
  $keystore_password_file   = 'keystore_password-file',
  $truststore               = $certs::candlepin_truststore,
  $truststore_password_file = 'truststore_password-file',
  $country                  = $certs::country,
  $state                    = $certs::state,
  $city                     = $certs::city,
  $org                      = $certs::org,
  $org_unit                 = $certs::org_unit,
  $expiration               = $certs::expiration,
  $default_ca               = $certs::default_ca,
  $ca_key_password_file     = $certs::ca_key_password_file,
  $user                     = $certs::user,
  $group                    = 'tomcat',
  $client_cert              = undef,
) inherits certs {

  $artemis_alias = 'artemis-client'
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
  $truststore_password = extlib::cache_data('foreman_cache_data', $truststore_password_file, extlib::random_password(32))
  $keystore_password_path = "${pki_dir}/keystore_password-file"
  $truststore_password_path = "${pki_dir}/truststore_password-file"
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
    file { $keystore_password_path:
      ensure  => file,
      content => $keystore_password,
      owner   => 'root',
      group   => $group,
      mode    => '0440',
    } ~>
    exec { 'candlepin-generate-ssl-keystore':
      command   => "openssl pkcs12 -export -in ${tomcat_cert} -inkey ${tomcat_key} -out ${keystore} -name tomcat -CAfile ${ca_cert} -caname root -password \"file:${keystore_password_path}\"",
      unless    => "keytool -list -keystore ${keystore} -storepass:file ${keystore_password_path} -alias tomcat | grep $(openssl x509 -noout -fingerprint -in ${tomcat_cert} | cut -d '=' -f 2)",
      logoutput => 'on_failure',
      path      => ['/bin/', '/usr/bin'],
    } ~>
    file { $keystore:
      ensure => file,
      owner  => 'root',
      group  => $group,
      mode   => '0640',
    }

    file { $truststore_password_path:
      ensure  => file,
      content => $truststore_password,
      owner   => 'root',
      group   => $group,
      mode    => '0440',
    }

    truststore_certificate { "${truststore}:${alias}":
      ensure        => present,
      password_file => $truststore_password_path,
      certificate   => $ca_cert,
    }

    truststore_certificate { "${truststore}:${artemis_alias}":
      ensure        => present,
      password_file => $truststore_password_path,
      certificate   => $client_cert,
    }

    file { $truststore:
      ensure => file,
      owner  => 'root',
      group  => $group,
      mode   => '0640',
    }
  }
}
