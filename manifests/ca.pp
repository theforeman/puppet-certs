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
  Optional[Stdlib::Absolutepath] $server_cert = $certs::server_cert,
  Optional[Stdlib::Absolutepath] $ssl_build_dir = $certs::ssl_build_dir,
  String $group = $certs::group,
  String $owner = $certs::user,
  Stdlib::Absolutepath $katello_server_ca_cert = $certs::katello_server_ca_cert,
  Stdlib::Absolutepath $ca_key = $certs::ca_key,
  Stdlib::Absolutepath $ca_cert = $certs::ca_cert,
  Stdlib::Absolutepath $ca_cert_stripped = $certs::ca_cert_stripped,
  String $ca_key_password = $certs::ca_key_password,
  Stdlib::Absolutepath $ca_key_password_file = $certs::ca_key_password_file,
) {
  file { "${certs::pki_dir}/private/${default_ca_name}.pwd":
    ensure => absent,
  }

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
    deploy        => false,
    password_file => $ca_key_password_file,
    build_dir     => $certs::ssl_build_dir,
  }
  $default_ca = Ca[$default_ca_name]

  if $server_cert {
    ca { $server_ca_name:
      ensure        => present,
      generate      => $generate,
      deploy        => false,
      custom_pubkey => $certs::server_ca_cert,
      build_dir     => $certs::ssl_build_dir,
    }
  } else {
    ca { $server_ca_name:
      ensure        => present,
      generate      => $generate,
      deploy        => false,
      custom_pubkey => "${certs::ssl_build_dir}/${default_ca_name}.crt",
      build_dir     => $certs::ssl_build_dir,
    }
  }

  if $generate {
    file { "${ssl_build_dir}/KATELLO-TRUSTED-SSL-CERT":
      ensure  => link,
      target  => "${ssl_build_dir}/${server_ca_name}.crt",
      require => Ca[$server_ca_name],
    }
  }

  if $deploy {
    # Ensure CA key deployed to /etc/pki/katello/private no longer exists
    # The CA key is not used by anything from this directory and does not need to be deployed
    file { $ca_key:
      ensure => absent,
    }

    file { $certs::katello_default_ca_cert:
      ensure => file,
      source => "${certs::ssl_build_dir}/${default_ca_name}.crt",
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
    }

    file { $katello_server_ca_cert:
      ensure => file,
      source => "${certs::ssl_build_dir}/${server_ca_name}.crt",
      owner  => $owner,
      group  => $group,
      mode   => '0644',
    }
  }
}
