# Class for handling Puppet cert configuration
class certs::puppet (
  Stdlib::Fqdn $hostname = $certs::node_fqdn,
  Array[Stdlib::Fqdn] $cname = $certs::cname,
  Boolean $generate = $certs::generate,
  Boolean $regenerate = $certs::regenerate,
  Boolean $deploy = $certs::deploy,
  Stdlib::Absolutepath $client_cert = $certs::puppet_client_cert,
  Stdlib::Absolutepath $client_key = $certs::puppet_client_key,
  Stdlib::Absolutepath $ssl_ca_cert = $certs::puppet_ssl_ca_cert,
  String[2,2] $country = $certs::country,
  String $state = $certs::state,
  String $city = $certs::city,
  Variant[String, Integer] $expiration = $certs::expiration,
  Stdlib::Absolutepath $ca_key_password_file = $certs::ca_key_password_file,
  Stdlib::Absolutepath $server_ca = $certs::katello_server_ca_cert,
  Stdlib::Absolutepath $pki_dir = $certs::pki_dir,
  String $owner = 'root',
  String $group = 'puppet',
) inherits certs {
  $puppet_client_cert_name = "${hostname}-puppet-client"
  $puppet_client_cert_path = "${certs::ssl_build_dir}/${hostname}/${puppet_client_cert_name}"

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

    openssl::certificate::x509 { $puppet_client_cert_name:
      ensure         => present,
      commonname     => $hostname,
      country        => $country,
      state          => $state,
      locality       => $city,
      organization   => 'FOREMAN',
      unit           => 'PUPPET',
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
    file { "${pki_dir}/puppet":
      ensure => directory,
      owner  => $owner,
      group  => $group,
      mode   => '0750',
    }

    certs::keypair { $puppet_client_cert_name:
      source_dir => "${certs::ssl_build_dir}/${hostname}",
      key_file   => $client_key,
      key_owner  => $owner,
      key_group  => $group,
      key_mode   => '0440',
      cert_file  => $client_cert,
      cert_owner => $owner,
      cert_group => $group,
      cert_mode  => '0440',
      require    => X509_cert["${puppet_client_cert_path}.crt"],
    }

    file { $ssl_ca_cert:
      ensure  => file,
      source  => $server_ca,
      owner   => $owner,
      group   => $group,
      mode    => '0440',
      require => File[$server_ca],
    }
  }
}
