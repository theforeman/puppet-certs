# Certs configurations for Apache
class certs::apache (
  $hostname             = $certs::node_fqdn,
  $cname                = $certs::cname,
  $generate             = $certs::generate,
  $regenerate           = $certs::regenerate,
  Boolean $deploy = $certs::deploy,
  Stdlib::Absolutepath $pki_dir = $certs::pki_dir,
  Optional[Stdlib::Absolutepath] $server_cert          = $certs::server_cert,
  Optional[Stdlib::Absolutepath] $server_key           = $certs::server_key,
  $country              = $certs::country,
  $state                = $certs::state,
  $city                 = $certs::city,
  $org                  = $certs::org,
  $org_unit             = $certs::org_unit,
  $expiration           = $certs::expiration,
  $default_ca           = $certs::default_ca,
  $ca_key_password_file = $certs::ca_key_password_file,
  $group                = 'root',
) inherits certs {

  $apache_cert_name = "${hostname}-apache"
  $apache_cert = "${pki_dir}/certs/katello-apache.crt"
  $apache_key  = "${pki_dir}/private/katello-apache.key"
  $apache_ca_cert = $certs::katello_server_ca_cert

  if $server_cert {
    $cert_source = $server_cert
    $key_source = $server_key
    $require = undef
  } else {
    cert { $apache_cert_name:
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
      deploy        => false,
      password_file => $ca_key_password_file,
      build_dir     => $certs::ssl_build_dir,
    }

    $cert_source = "${certs::ssl_build_dir}/${hostname}/${apache_cert_name}.crt"
    $key_source = "${certs::ssl_build_dir}/${hostname}/${apache_cert_name}.key"
    $require = Cert[$apache_cert_name]
  }

  if $deploy {
    certs::key_pair { 'apache':
      key_destination  => $apache_key,
      key_source       => $key_source,
      key_group        => $group,
      cert_destination => $apache_cert,
      cert_source      => $cert_source,
      require          => $require,
    }
  }
}
