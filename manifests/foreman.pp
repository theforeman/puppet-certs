# Handles Foreman certs configuration
class certs::foreman (
  Stdlib::Fqdn $hostname = $certs::node_fqdn,
  Array[Stdlib::Fqdn] $cname = $certs::cname,
  Boolean $generate = $certs::generate,
  Boolean $regenerate = $certs::regenerate,
  Boolean $deploy = $certs::deploy,
  Stdlib::Absolutepath $client_cert = '/etc/foreman/client_cert.pem',
  Stdlib::Absolutepath $client_key = '/etc/foreman/client_key.pem',
  Stdlib::Absolutepath $ssl_ca_cert = '/etc/foreman/proxy_ca.pem',
  String[2,2] $country = $certs::country,
  String $state = $certs::state,
  String $city = $certs::city,
  String $org = 'FOREMAN',
  String $org_unit = 'PUPPET',
  Variant[String, Integer] $expiration = $certs::expiration,
  Stdlib::Absolutepath $ca_key_password_file = $certs::ca_key_password_file,
  Stdlib::Absolutepath $server_ca = $certs::katello_server_ca_cert,
  String $owner = 'root',
  String $group = 'foreman',
) inherits certs {
  $client_cert_name = "${hostname}-foreman-client"
  $client_cert_path = "${certs::ssl_build_dir}/${hostname}/${client_cert_name}"
  $client_dn = "CN=${hostname}, OU=${org_unit}, O=${org}, ST=${state}, C=${country}"

  if $generate {
    ensure_resource(
      'file',
      "${certs::ssl_build_dir}/${hostname}",
      {
        'ensure' => directory,
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0750',
      }
    )

    openssl::certificate::x509 { $client_cert_name:
      ensure         => present,
      commonname     => $hostname,
      country        => $country,
      state          => $state,
      locality       => $city,
      organization   => $org,
      unit           => $org_unit,
      altnames       => $cname,
      extkeyusage    => ['clientAuth'],
      days           => $expiration,
      base_dir       => "${certs::ssl_build_dir}/${hostname}",
      key_size       => 4096,
      force          => true,
      encrypted      => false,
      ca             => "${certs::ssl_build_dir}/${certs::default_ca_name}.crt",
      cakey          => "${certs::ssl_build_dir}/${certs::default_ca_name}.key",
      cakey_password => $certs::ca_key_password,
    }
  }

  if $deploy {
    certs::keypair { $client_cert_name:
      source_dir => "${certs::ssl_build_dir}/${hostname}",
      key_file   => $client_key,
      key_owner  => $owner,
      key_group  => $group,
      key_mode   => '0440',
      cert_file  => $client_cert,
      cert_owner => $owner,
      cert_group => $group,
      cert_mode  => '0440',
      require    => X509_cert["${client_cert_path}.crt"],
    }

    file { $ssl_ca_cert:
      ensure  => file,
      source  => $server_ca,
      owner   => 'root',
      group   => $group,
      mode    => '0440',
      require => File[$server_ca],
    }
  }
}
