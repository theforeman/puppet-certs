# Certs configurations for MongoDB
class certs::mongodb (
  $hostname             = $certs::node_fqdn,
  $cname                = $certs::cname,
  $generate             = $certs::generate,
  $regenerate           = $certs::regenerate,
  $deploy               = $certs::deploy,
  $pki_dir              = $certs::pki_dir,
  $server_cert          = $certs::server_cert,
  $country              = $certs::country,
  $state                = $certs::state,
  $city                 = $certs::city,
  $org                  = $certs::org,
  $org_unit             = $certs::org_unit,
  $expiration           = $certs::expiration,
  $default_ca           = $certs::default_ca,
  $ca_key_password_file = $certs::ca_key_password_file,
  $group                = 'mongodb',
) inherits certs {

  $mongodb_server_cert_name = 'mongodb-server-certificate'
  $mongodb_server_bundle = "${pki_dir}/mongodb/${mongodb_server_cert_name}-bundle.pem"
  $mongodb_server_ca_cert = $certs::katello_server_ca_cert

  cert { $mongodb_server_cert_name:
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

  if $deploy {
    file { "${pki_dir}/mongodb":
      ensure => directory,
      mode   => '0750',
      owner  => 'root',
      group  => $group,
    }

    key_bundle { $mongodb_server_bundle:
      key_pair  => Cert[$mongodb_server_cert_name],
      force_rsa => true,
    } ~>
    file { $mongodb_server_bundle:
      ensure => file,
      mode   => '0440',
      owner  => 'root',
      group  => $group,
    }
  }
}
