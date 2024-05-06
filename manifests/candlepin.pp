# Constains certs specific configurations for candlepin
class certs::candlepin (
  Stdlib::Fqdn $hostname = $certs::node_fqdn,
  Array[Stdlib::Fqdn] $cname = $certs::cname,
  Boolean $generate = $certs::generate,
  Boolean $regenerate = $certs::regenerate,
  Boolean $deploy = $certs::deploy,
  Stdlib::Absolutepath $ca_cert = $certs::candlepin_ca_cert,
  Stdlib::Absolutepath $ca_key = $certs::candlepin_ca_key,
  Stdlib::Absolutepath $pki_dir = $certs::pki_dir,
  Stdlib::Absolutepath $keystore = $certs::candlepin_keystore,
  String $keystore_password_file = 'keystore_password-file',
  Stdlib::Absolutepath $truststore = $certs::candlepin_truststore,
  String $truststore_password_file = 'truststore_password-file',
  String[2,2] $country = $certs::country,
  String $state = $certs::state,
  String $city = $certs::city,
  String $org = $certs::org,
  String $org_unit = $certs::org_unit,
  Variant[String, Integer] $expiration = $certs::expiration,
  Stdlib::Absolutepath $ca_key_password_file = $certs::ca_key_password_file,
  String $user = 'root',
  String $group = 'tomcat',
  String $client_keypair_group = 'tomcat',
) inherits certs {
  include certs::foreman

  $artemis_alias = 'artemis-client'
  $tomcat_cert_name = "${hostname}-tomcat"
  $tomcat_cert_path = "${certs::ssl_build_dir}/${hostname}/${tomcat_cert_name}"

  if $generate {
    ensure_resource(
      'file',
      "${certs::ssl_build_dir}/${hostname}",
      {
        'ensure' => directory,
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0750',
      }
    )

    openssl::certificate::x509 { $tomcat_cert_name:
      ensure         => present,
      commonname     => $hostname,
      country        => $country,
      state          => $state,
      locality       => $city,
      organization   => $org,
      unit           => $org_unit,
      altnames       => $cname,
      extkeyusage    => ['serverAuth'],
      days           => $expiration,
      base_dir       => "${certs::ssl_build_dir}/${hostname}",
      key_size       => 4096,
      force          => true,
      encrypted      => false,
      ca             => "${certs::ssl_build_dir}/${certs::default_ca_name}.crt",
      cakey          => "${certs::ssl_build_dir}/${certs::default_ca_name}.key",
      cakey_password => $certs::ca_key_password,
    }
  }

  $keystore_password = extlib::cache_data('foreman_cache_data', $keystore_password_file, extlib::random_password(32))
  $truststore_password = extlib::cache_data('foreman_cache_data', $truststore_password_file, extlib::random_password(32))
  $keystore_password_path = "${pki_dir}/${keystore_password_file}"
  $truststore_password_path = "${pki_dir}/${truststore_password_file}"
  $client_key = $certs::foreman::client_key
  $client_cert = $certs::foreman::client_cert
  $alias = 'candlepin-ca'

  if $deploy {
    certs::keypair { $certs::default_ca_name:
      source_dir        => $certs::ssl_build_dir,
      key_file          => $ca_key,
      key_owner         => $user,
      key_group         => $group,
      key_mode          => '0440',
      cert_file         => $ca_cert,
      cert_owner        => $user,
      cert_group        => $group,
      cert_mode         => '0440',
      require           => X509_cert["${tomcat_cert_path}.crt"],
      key_password_file => $ca_key_password_file,
      key_decrypt       => true,
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
      certificate   => "${certs::ssl_build_dir}/${hostname}/${tomcat_cert_name}.crt",
      private_key   => "${certs::ssl_build_dir}/${hostname}/${tomcat_cert_name}.key",
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
