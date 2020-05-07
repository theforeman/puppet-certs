# Certs configurations for MongoDB
class certs::mongodb_client (
  $hostname             = $certs::node_fqdn,
  $cname                = $certs::cname,
  $generate             = $certs::generate,
  $regenerate           = $certs::regenerate,
  $deploy               = $certs::deploy,
  $pki_dir              = '/etc/pulp/mongodb',
  $server_cert          = $certs::server_cert,
  $country              = $certs::country,
  $state                = $certs::state,
  $city                 = $certs::city,
  $org                  = $certs::org,
  $org_unit             = $certs::org_unit,
  $expiration           = $certs::expiration,
  $default_ca           = $certs::default_ca,
  $ca_key_password_file = $certs::ca_key_password_file,
  $group                = 'pulp',
) inherits certs {

  $mongodb_client_cert_name = 'mongodb-client-certificate'
  $mongodb_client_cert = "${pki_dir}/${mongodb_client_cert_name}.crt"
  $mongodb_client_key  = "${pki_dir}/${mongodb_client_cert_name}.key"
  $mongodb_client_ca_cert = $certs::katello_server_ca_cert

  cert { $mongodb_client_cert_name:
    ensure        => present,
    hostname      => $hostname,
    cname         => $cname,
    purpose       => 'client',
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
    file { $pki_dir:
      ensure => directory,
      owner  => 'root',
      group  => $group,
      mode   => '0770',
    } ->
    certs::keypair { 'mongodb_client':
      key_pair    => Cert[$mongodb_client_cert_name],
      key_file    => $mongodb_client_key,
      manage_key  => true,
      key_owner   => 'root',
      key_group   => $group,
      key_mode    => '0440',
      manage_cert => true,
      cert_owner  => 'root',
      cert_group  => $group,
      cert_mode   => '0440',
      cert_file   => $mongodb_client_cert,
    }
  }
}
