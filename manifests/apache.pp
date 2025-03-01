# Certs configurations for Apache
#
# === Parameters:
#
# $hostname::             The fqdn of the host the generated certificates
#                         should be for
#
# $cname::                The alternative names of the host the generated certificates
#                         should be for
#
# $server_cert::          Path to the ssl certificate for https
#                         if not specified, the default CA will generate one
#
# $server_key::           Path to the ssl key for https
#                         if not specified, the default CA will generate one
#
# $server_cert_req::      Path to the ssl certificate request for https
#                         if not specified, the default CA will generate one
#
# === Advanced parameters:
#
# $generate::             Should the generation of the certs be part of the
#                         configuration
#
# $regenerate::           Force regeneration of the certificates (excluding
#                         CA certificates)
#
# $deploy::               Deploy the certs on the configured system. False means
#                         we want to apply it to a different system
#
# $country::              Country attribute for managed certificates
#
# $state::                State attribute for managed certificates
#
# $city::                 City attribute for managed certificates
#
# $org::                  Org attribute for managed certificates
#
# $org_unit::             Org unit attribute for managed certificates
#
# $expiration::           Expiration attribute for managed certificates
#
# $pki_dir::              The PKI directory under which to place certs
#
# $group::                The group who should own the certs
#
# $ca_key_password_file:: Location of the password file for the CA key
class certs::apache (
  Stdlib::Fqdn $hostname = $certs::node_fqdn,
  Array[Stdlib::Fqdn] $cname = $certs::cname,
  Boolean $generate = $certs::generate,
  Boolean $regenerate = $certs::regenerate,
  Boolean $deploy = $certs::deploy,
  Stdlib::Absolutepath $pki_dir = $certs::pki_dir,
  Optional[Stdlib::Absolutepath] $server_cert = $certs::server_cert,
  Optional[Stdlib::Absolutepath] $server_key = $certs::server_key,
  String[2,2] $country = $certs::country,
  String $state = $certs::state,
  String $city = $certs::city,
  String $org = $certs::org,
  String $org_unit = $certs::org_unit,
  String $expiration = $certs::expiration,
  Stdlib::Absolutepath $ca_key_password_file = $certs::ca_key_password_file,
  String $group = $certs::group,
) inherits certs {
  $apache_cert_name = "${hostname}-apache"
  $apache_cert = "${pki_dir}/certs/katello-apache.crt"
  $apache_key  = "${pki_dir}/private/katello-apache.key"

  # These variables are unused but considered public API
  $apache_ca_cert = $certs::katello_server_ca_cert
  $apache_client_ca_cert = $certs::katello_default_ca_cert

  $apache_cert_path = "${certs::ssl_build_dir}/${hostname}/${apache_cert_name}"

  if $server_cert {
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
    file { "${apache_cert_path}.crt":
      ensure => file,
      source => $server_cert,
      owner  => 'root',
      group  => 'root',
      mode   => '0440',
    }
    file { "${apache_cert_path}.key":
      ensure => file,
      source => $server_key,
      owner  => 'root',
      group  => 'root',
      mode   => '0440',
    }

    $require_cert = File["${apache_cert_path}.crt"]
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
      ca            => $certs::default_ca,
      generate      => $generate,
      regenerate    => $regenerate,
      password_file => $ca_key_password_file,
      build_dir     => $certs::ssl_build_dir,
    }

    $require_cert = Cert[$apache_cert_name]
  }

  if $deploy {
    include certs::config::deploy
    require certs::ca

    certs::keypair { $apache_cert_name:
      source_dir => "${certs::ssl_build_dir}/${hostname}",
      key_file   => $apache_key,
      key_owner  => 'root',
      key_group  => $group,
      key_mode   => '0440',
      cert_file  => $apache_cert,
      cert_owner => 'root',
      cert_group => $group,
      cert_mode  => '0440',
      require    => $require_cert,
    }

    file { $certs::katello_default_ca_cert:
      ensure => file,
      source => $certs::ca::default_ca_path,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
    }

    file { $certs::katello_server_ca_cert:
      ensure => file,
      source => $certs::ca::server_ca_path,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
    }
  }
}
