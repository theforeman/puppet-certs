# Certs configurations for Apache
class certs::apache (

  $hostname        = $::certs::node_fqdn,
  $cname           = $::certs::cname,
  $generate        = $::certs::generate,
  $regenerate      = $::certs::regenerate,
  $deploy          = $::certs::deploy,
) inherits certs::params {

  $apache_cert_name = "${hostname}-apache"
  $apache_cert = "${::certs::pki_dir}/certs/katello-apache.crt"
  $apache_key  = "${::certs::pki_dir}/private/katello-apache.key"

  if $::certs::server_cert {
    cert { $apache_cert_name:
      ensure         => present,
      hostname       => $hostname,
      cname          => $cname,
      generate       => $generate,
      deploy         => $deploy,
      regenerate     => $regenerate,
      custom_pubkey  => $::certs::server_cert,
      custom_privkey => $::certs::server_key,
      custom_req     => $::certs::server_cert_req,
    }
  } else {
    cert { $apache_cert_name:
      ensure        => present,
      hostname      => $hostname,
      cname         => $cname,
      country       => $::certs::country,
      state         => $::certs::state,
      city          => $::certs::city,
      org           => $::certs::org,
      org_unit      => $::certs::org_unit,
      expiration    => $::certs::expiration,
      ca            => $::certs::default_ca,
      generate      => $generate,
      regenerate    => $regenerate,
      deploy        => $deploy,
      password_file => $::certs::ca_key_password_file,
    }
  }

  if $deploy {

    include ::apache

    certs::keypair { 'apache':
      key_pair   => $apache_cert_name,
      key_file   => $apache_key,
      manage_key => true,
      key_owner  => $::apache::user,
      key_mode   => '0440',
      key_group  => $::certs::group,
      cert_file  => $apache_cert,
      notify     => Service['httpd'],
    }
  }
}
