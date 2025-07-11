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
  String $owner = $certs::user,
  String $group = $certs::group,
  String $ca_key_password = $certs::ca_key_password,
  Stdlib::Absolutepath $ca_key_password_file = $certs::ca_key_password_file,
) {
  $default_ca_path = "${certs::ssl_build_dir}/${default_ca_name}.crt"
  $server_ca_path = "${certs::ssl_build_dir}/${server_ca_name}.crt"
  $ca_bundle_path = "${certs::ssl_build_dir}/ca-bundle.crt"

  if $generate {
    file { $ca_key_password_file:
      ensure    => file,
      content   => $ca_key_password,
      owner     => 'root',
      group     => 'root',
      mode      => '0400',
      show_diff => false,
      notify    => Ca[$default_ca_name],
    }
  }

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
    file { $server_ca_path:
      ensure => file,
      source => pick($certs::server_ca_cert, $default_ca_path),
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
    }

    concat { $ca_bundle_path:
      ensure => present,
    }

    concat::fragment { 'default-ca':
      target => $ca_bundle_path,
      source => $default_ca_path,
      order  => '01',
    }

    if $certs::server_ca_cert {
      concat::fragment { 'server-ca':
        target => $ca_bundle_path,
        source => $server_ca_path,
        order  => '02',
      }
    }
  }
}
