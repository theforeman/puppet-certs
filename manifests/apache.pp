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
  Stdlib::Fqdn $hostname,
  Array[Stdlib::Fqdn] $cname,
  Boolean $generate,
  Boolean $regenerate,
  Boolean $deploy,
  Stdlib::Absolutepath $pki_dir,
  String[2,2] $country,
  String $state,
  String $city,
  String $org,
  String $org_unit,
  String $expiration,
  Stdlib::Absolutepath $ca_key_password_file,
  String $group,
  Optional[Stdlib::Absolutepath] $server_cert = undef,
  Optional[Stdlib::Absolutepath] $server_key = undef,
  Optional[Stdlib::Absolutepath] $server_cert_req = undef,
) inherits certs {
  $apache_cert_name = "${hostname}-apache"
  $apache_cert = "${pki_dir}/certs/katello-apache.crt"
  $apache_key  = "${pki_dir}/private/katello-apache.key"
  # This variable is unused but considered public API
  $apache_ca_cert = $certs::katello_server_ca_cert

  if $server_cert {
    cert { $apache_cert_name:
      ensure         => present,
      hostname       => $hostname,
      cname          => $cname,
      generate       => $generate,
      deploy         => false,
      regenerate     => $regenerate,
      custom_pubkey  => pick($server_cert, $certs::server_cert),
      custom_privkey => pick($server_key, $certs::server_key),
      custom_req     => pick($server_cert_req, $certs::server_cert_req),
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
      ca            => $certs::default_ca,
      generate      => $generate,
      regenerate    => $regenerate,
      deploy        => false,
      password_file => $ca_key_password_file,
      build_dir     => $certs::ssl_build_dir,
    }
  }

  if $deploy {
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
      require    => Cert[$apache_cert_name],
    }
  }
}
