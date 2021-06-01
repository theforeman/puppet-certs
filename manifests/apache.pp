# Certs configurations for Apache
class certs::apache (
  $hostname             = $certs::node_fqdn,
  $cname                = $certs::cname,
  $generate             = $certs::generate,
  $regenerate           = $certs::regenerate,
  $deploy               = $certs::deploy,
  $pki_dir              = $certs::pki_dir,
  $server_cert          = $certs::server_cert,
  $server_key           = $certs::server_key,
  $server_cert_req      = $certs::server_cert_req,
  $country              = $certs::country,
  $state                = $certs::state,
  $city                 = $certs::city,
  $org                  = $certs::org,
  $org_unit             = $certs::org_unit,
  $expiration           = $certs::expiration,
  $default_ca           = $certs::default_ca,
  $ca_key_password_file = $certs::ca_key_password_file,
  $group                = $certs::group,
) inherits certs {

  $apache_cert_name = "${hostname}-apache"
  $apache_cert = "${pki_dir}/certs/katello-apache.crt"
  $apache_key  = "${pki_dir}/private/katello-apache.key"
  $apache_ca_cert = $certs::katello_server_ca_cert

  if $server_cert {
    cert { $apache_cert_name:
      ensure         => present,
      hostname       => $hostname,
      cname          => $cname,
      generate       => $generate,
      deploy         => false,
      regenerate     => $regenerate,
      custom_pubkey  => $server_cert,
      custom_privkey => $server_key,
      custom_req     => $server_cert_req,
      build_dir      => $certs::ssl_build_dir,
    }
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
  }

  if $deploy {
    file { $apache_key:
      ensure  => file,
      source  => "${certs::ssl_build_dir}/${hostname}/${apache_cert_name}.key",
      owner   => 'root',
      group   => $group,
      mode    => '0440',
      require => Cert[$apache_cert_name],
    }

    file { $apache_cert:
      ensure  => file,
      source  => "${certs::ssl_build_dir}/${hostname}/${apache_cert_name}.crt",
      owner   => 'root',
      group   => $group,
      mode    => '0640',
      require => Cert[$apache_cert_name],
    }
  }
}
