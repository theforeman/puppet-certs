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
  $client_keypair_group     = 'tomcat',
) inherits certs {
  include certs::foreman

  $java_client_cert_name = 'java-client'
  $artemis_alias = 'artemis-client'
  $artemis_client_dn = $certs::foreman::client_dn

  cert { $java_client_cert_name:
    ensure        => absent,
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
    build_dir     => $certs::ssl_build_dir,
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
    build_dir     => $certs::ssl_build_dir,
  }

  $keystore_password = extlib::cache_data('foreman_cache_data', $keystore_password_file, extlib::random_password(32))
  $truststore_password = extlib::cache_data('foreman_cache_data', $truststore_password_file, extlib::random_password(32))
  $keystore_password_path = "${pki_dir}/${keystore_password_file}"
  $truststore_password_path = "${pki_dir}/${truststore_password_file}"
  $client_key = $certs::foreman::client_key
  $client_cert = $certs::foreman::client_cert
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
      strip         => true,
      password_file => $ca_key_password_file,
    }

    certs::keypair { 'tomcat':
      key_pair    => Cert[$tomcat_cert_name],
      key_file    => $tomcat_key,
      manage_key  => true,
      key_owner   => 'root',
      key_group   => $client_keypair_group,
      key_mode    => '0440',
      cert_file   => $tomcat_cert,
      manage_cert => true,
      cert_owner  => 'root',
      cert_group  => $client_keypair_group,
      cert_mode   => '0440',
    }

    certs::keypair { 'candlepin':
      key_pair    => Cert[$java_client_cert_name],
      key_file    => "${pki_dir}/private/${java_client_cert_name}.key",
      cert_file   => "${pki_dir}/certs/${java_client_cert_name}.crt",
      manage_cert => true,
      ensure_cert => 'absent',
      cert_owner  => 'root',
      cert_group  => $client_keypair_group,
      cert_mode   => '0440',
      manage_key  => true,
      ensure_key  => 'absent',
      key_owner   => 'root',
      key_group   => $client_keypair_group,
      key_mode    => '0440',
    }

    file { $keystore_password_path:
      ensure    => file,
      content   => $keystore_password,
      owner     => 'root',
      group     => $group,
      mode      => '0440',
      show_diff => false,
    }

    keystore { $keystore:
      ensure        => present,
      password_file => $keystore_password_path,
      owner         => 'root',
      group         => $group,
      mode          => '0640',
    }

    keystore_certificate { "${keystore}:tomcat":
      ensure        => present,
      password_file => $keystore_password_path,
      certificate   => $tomcat_cert,
      private_key   => $tomcat_key,
      ca            => $ca_cert,
    }

    file { $truststore_password_path:
      ensure    => file,
      content   => $truststore_password,
      owner     => 'root',
      group     => $group,
      mode      => '0440',
      show_diff => false,
    }

    truststore { $truststore:
      ensure        => present,
      password_file => $truststore_password_path,
      owner         => 'root',
      group         => $group,
      mode          => '0640',
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
  }
}
