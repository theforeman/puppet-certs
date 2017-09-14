# Certs configurations for Apache
class certs::apache (
  $hostname             = $::certs::node_fqdn,
  $cname                = $::certs::cname,
  $generate             = $::certs::generate,
  $regenerate           = $::certs::regenerate,
  $deploy               = $::certs::deploy,
  $pki_dir              = $::certs::pki_dir,
  $server_cert          = $::certs::server_cert,
  $server_key           = $::certs::server_key,
  $server_cert_req      = $::certs::server_cert_req,
  $country              = $::certs::country,
  $state                = $::certs::state,
  $city                 = $::certs::city,
  $org                  = $::certs::org,
  $org_unit             = $::certs::org_unit,
  $expiration           = $::certs::expiration,
  $default_ca           = $::certs::default_ca,
  $ca_key_password_file = $::certs::ca_key_password_file,
) inherits certs {

  $apache_cert_name = "${hostname}-apache"
  $apache_cert = "${pki_dir}/certs/katello-apache.crt"
  $apache_key  = "${pki_dir}/private/katello-apache.key"

  if $server_cert {
    cert { $apache_cert_name:
      ensure         => present,
      hostname       => $hostname,
      cname          => $cname,
      generate       => $generate,
      deploy         => $deploy,
      regenerate     => $regenerate,
      custom_pubkey  => $server_cert,
      custom_privkey => $server_key,
      custom_req     => $server_cert_req,
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
      deploy        => $deploy,
      password_file => $ca_key_password_file,
    }
  }

  if $deploy {
    certs::keypair { 'apache':
      key_pair   => $apache_cert_name,
      key_file   => $apache_key,
      manage_key => true,
      key_owner  => 'root',
      key_group  => 'root',
      key_mode   => '0440',
      cert_file  => $apache_cert,
    }
  }
}
