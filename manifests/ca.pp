# @summary set up the CA for Katello
# @api private
class certs::ca (
  String $default_ca_name = $certs::default_ca_name,
  String $server_ca_name = $certs::server_ca_name,
  Stdlib::Fqdn $ca_common_name = $certs::ca_common_name,
  String[2,2] $country = $certs::country,
  String $state = $certs::state,
  String $city = $certs::city,
  String $org = $certs::org,
  String $org_unit = $certs::org_unit,
  String $ca_expiration = $certs::ca_expiration,
  Boolean $generate = $certs::generate,
  Boolean $deploy = $certs::deploy,
  String $owner = $certs::user,
  String $group = $certs::group,
  Stdlib::Absolutepath $katello_server_ca_cert = $certs::katello_server_ca_cert,
  Stdlib::Absolutepath $ca_key = $certs::ca_key,
  Stdlib::Absolutepath $ca_cert = $certs::ca_cert,
  Stdlib::Absolutepath $ca_cert_stripped = $certs::ca_cert_stripped,
  String $ca_key_password = $certs::ca_key_password,
  Stdlib::Absolutepath $ca_key_password_file = $certs::ca_key_password_file,
) {
  $server_ca_path = "${certs::ssl_build_dir}/${server_ca_name}.crt"

  file { $ca_key_password_file:
    ensure    => file,
    content   => $ca_key_password,
    owner     => 'root',
    group     => 'root',
    mode      => '0400',
    show_diff => false,
  }

  openssl::config { "${certs::ssl_build_dir}/ca.cnf":
    ensure            => 'present',
    commonname        => $certs::node_fqdn,
    country           => $country,
    state             => $state,
    locality          => $city,
    organization      => $org,
    unit              => $org_unit,
    default_keyfile   => "${default_ca_name}.key",
    basicconstraints  => ['CA:true'],
    keyusages         => ['digitalSignature', 'keyEncipherment', 'keyCertSign', 'cRLSign'],
    extendedkeyusages => ['serverAuth', 'clientAuth'],
  }

  ssl_pkey { "${certs::ssl_build_dir}/${default_ca_name}.key":
    ensure   => 'present',
    password => $ca_key_password,
    size     => '4096',
  }

  x509_cert { "${certs::ssl_build_dir}/${default_ca_name}.crt":
    ensure      => 'present',
    private_key => "${certs::ssl_build_dir}/${default_ca_name}.key",
    days        => $ca_expiration,
    template    => "${certs::ssl_build_dir}/ca.cnf",
    password    => $ca_key_password,
    require     => File["${certs::ssl_build_dir}/ca.cnf"],
  }

  if $certs::server_ca_cert {
    file { $server_ca_path:
      ensure => file,
      source => $certs::server_ca_cert,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
    }
  } else {
    file { $server_ca_path:
      ensure  => file,
      source  => "${certs::ssl_build_dir}/${default_ca_name}.crt",
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => X509_cert["${certs::ssl_build_dir}/${default_ca_name}.crt"],
    }
  }

  if $deploy {
    file { $certs::katello_default_ca_cert:
      ensure  => file,
      source  => "${certs::ssl_build_dir}/${default_ca_name}.crt",
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => X509_cert["${certs::ssl_build_dir}/${default_ca_name}.crt"],
    }

    file { $katello_server_ca_cert:
      ensure  => file,
      source  => $server_ca_path,
      owner   => $owner,
      group   => $group,
      mode    => '0644',
      require => File[$server_ca_path],
    }
  }
}
