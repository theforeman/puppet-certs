# == Class: certs
# Sets up the CA for Katello
class certs::ca (
  $default_ca_name         = $certs::default_ca_name,
  $server_ca_name          = $certs::server_ca_name,
  $ca_common_name          = $certs::ca_common_name,
  $country                 = $certs::country,
  $state                   = $certs::state,
  $city                    = $certs::city,
  $org                     = $certs::org,
  $org_unit                = $certs::org_unit,
  $ca_expiration           = $certs::ca_expiration,
  $generate                = $certs::generate,
  $deploy                  = $certs::deploy,
  $server_cert             = $certs::server_cert,
  $ssl_build_dir           = $certs::ssl_build_dir,
  $group                   = $certs::group,
  $katello_server_ca_cert  = $certs::katello_server_ca_cert,
  $ca_key                  = $certs::ca_key,
  $ca_cert                 = $certs::ca_cert,
  $ca_cert_stripped        = $certs::ca_cert_stripped,
  $ca_key_password         = $certs::ca_key_password,
  $ca_key_password_file    = $certs::ca_key_password_file,
  $other_default_ca_certs  = $::certs::other_default_ca_certs,
) {

  file { $ca_key_password_file:
    ensure  => file,
    content => $ca_key_password,
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
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
    other_certs   => $other_default_ca_certs,
  }
  $default_ca = Ca[$default_ca_name]

  if $server_cert {
    ca { $server_ca_name:
      ensure        => present,
      generate      => $generate,
      deploy        => $deploy,
      custom_pubkey => $certs::server_ca_cert,
    }
  } else {
    ca { $server_ca_name:
      ensure   => present,
      generate => $generate,
      deploy   => $deploy,
      ca       => $default_ca,
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
