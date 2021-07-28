# == Class: certs
# Sets up the CA for Katello
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
  Optional[Stdlib::Absolutepath] $server_cert = $certs::server_cert,
  Optional[Stdlib::Absolutepath] $ssl_build_dir = $certs::ssl_build_dir,
  String $group = $certs::group,
  Stdlib::Absolutepath $katello_server_ca_cert = $certs::katello_server_ca_cert,
  Stdlib::Absolutepath $ca_key = $certs::ca_key,
  Stdlib::Absolutepath $ca_cert = $certs::ca_cert,
  Stdlib::Absolutepath $ca_cert_stripped = $certs::ca_cert_stripped,
  String $ca_key_password = $certs::ca_key_password,
  Stdlib::Absolutepath $ca_key_password_file = $certs::ca_key_password_file,
) {

  file { $ca_key_password_file:
    ensure    => file,
    content   => $ca_key_password,
    owner     => 'root',
    group     => 'root',
    mode      => '0400',
    show_diff => false,
  } ~>
  ca { $default_ca_name:
    ensure        => present,
    common_name   => $ca_common_name,
    country       => $country,
    state         => $state,
    city          => $city,
    org           => $org,
    org_unit      => $org_unit,
    expiration    => $ca_expiration,
    generate      => $generate,
    deploy        => $deploy,
    password_file => $ca_key_password_file,
    build_dir     => $certs::ssl_build_dir,
  }
  $default_ca = Ca[$default_ca_name]

  if $server_cert {
    ca { $server_ca_name:
      ensure        => present,
      generate      => $generate,
      deploy        => $deploy,
      custom_pubkey => $certs::server_ca_cert,
      build_dir     => $certs::ssl_build_dir,
    }
  } else {
    ca { $server_ca_name:
      ensure    => present,
      generate  => $generate,
      deploy    => $deploy,
      ca        => $default_ca,
      build_dir => $certs::ssl_build_dir,
    }
  }
  $server_ca = Ca[$server_ca_name]

  if $generate {
    file { "${ssl_build_dir}/KATELLO-TRUSTED-SSL-CERT":
      ensure  => link,
      target  => "${ssl_build_dir}/${server_ca_name}.crt",
      require => $server_ca,
    }
  }

  if $deploy {
    Ca[$default_ca_name] ~>
    pubkey { $ca_cert:
      key_pair => $default_ca,
    } ~>
    pubkey { $ca_cert_stripped:
      strip    => true,
      key_pair => $default_ca,
    } ~>
    file { $ca_cert:
      ensure => file,
      owner  => 'root',
      group  => $group,
      mode   => '0644',
    }

    Ca[$server_ca_name] ~>
    pubkey { $katello_server_ca_cert:
      key_pair => $server_ca,
    } ~>
    file { $katello_server_ca_cert:
      ensure => file,
      owner  => 'root',
      group  => $group,
      mode   => '0644',
    }

    if $generate {
      Ca[$default_ca_name] ~>
      privkey { $ca_key:
        key_pair      => $default_ca,
        unprotect     => true,
        password_file => $ca_key_password_file,
      } ~>
      file { $ca_key:
        ensure => file,
        owner  => 'root',
        group  => $group,
        mode   => '0440',
      }
    }
  }
}
