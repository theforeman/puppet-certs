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
    password_file => $ca_key_password_file,
    build_dir     => $certs::ssl_build_dir,
  }

  if $generate {
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
        ensure => file,
        source => "${certs::ssl_build_dir}/${default_ca_name}.crt",
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
      }
    }

    file { "${certs::ssl_build_dir}/KATELLO-TRUSTED-SSL-CERT":
      ensure  => link,
      target  => $server_ca_path,
      require => File[$server_ca_path],
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
      source => $server_ca_path,
      owner  => $owner,
      group  => $group,
      mode   => '0644',
    }
  }
}
