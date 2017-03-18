# == Class: certs
#
# Base for installing and configuring certs. It holds the basic configuration
# aournd certificates generation and deployment. The per-subsystem configuratoin
# of certificates should go into `subsystem_module/manifests/certs.pp`.
#
# === Parameters:
#
# $node_fqdn::            The fqdn of the host the generated certificates
#                         should be for
#                         type:String
#
# $cname::                The alternative names of the host the generated certificates
#                         should be for
#                         type:array
#
# $server_ca_cert::       Path to the CA that issued the ssl certificates for https
#                         if not specified, the default CA will be used
#                         type:Optional[Stdlib::Absolutepath]
#
# $server_cert::          Path to the ssl certificate for https
#                         if not specified, the default CA will generate one
#                         type:Optional[Stdlib::Absolutepath]
#
# $server_key::           Path to the ssl key for https
#                         if not specified, the default CA will generate one
#                         type:Optional[Stdlib::Absolutepath]
#
# $server_cert_req::      Path to the ssl certificate request for https
#                         if not specified, the default CA will generate one
#                         type:Optional[Stdlib::Absolutepath]
#
# === Advanced parameters:
#
# $log_dir::              Where the log files should go
#                         type:Stdlib::Absolutepath
#
# $generate::             Should the generation of the certs be part of the
#                         configuration
#                         type:Boolean
#
# $regenerate::           Force regeneration of the certificates (excluding
#                         ca certificates)
#                         type:Boolean
#
# $regenerate_ca::        Force regeneration of the ca certificate
#                         type:Boolean
#
# $deploy::               Deploy the certs on the configured system. False means
#                         we want apply it on a different system
#                         type:Boolean
#
# $ca_common_name::       Common name for the generated CA certificate
#                         type:String
#
# $country::              Country attribute for managed certificates
#                         type:String[2]
#
# $state::                State attribute for managed certificates
#                         type:String
#
# $city::                 City attribute for managed certificates
#                         type:String
#
# $org::                  Org attribute for managed certificates
#                         type:String
#
# $org_unit::             Org unit attribute for managed certificates
#                         type:String
#
# $expiration::           Expiration attribute for managed certificates
#                         type:String
#
# $ca_expiration::        CA expiration attribute for managed certificates
#                         type:String
#
# $pki_dir::              The PKI directory under which to place certs
#                         type:Stdlib::Absolutepath
#
# $ssl_build_dir::        The directory where SSL keys, certs and RPMs will be generated
#                         type:Stdlib::Absolutepath
#
# $user::                 The system user name who should own the certs
#                         type:String
#
# $group::                The group who should own the certs
#                         type:String
#
# $default_ca_name::      The name of the default CA
#                         type:String
#
# $server_ca_name::       The name of the server CA (used for https)
#                         type:String
#
class certs (
  $log_dir         = $::certs::params::log_dir,
  $node_fqdn       = $::certs::params::node_fqdn,
  $cname           = $::certs::params::cname,
  $generate        = $::certs::params::generate,
  $regenerate      = $::certs::params::regenerate,
  $regenerate_ca   = $::certs::params::regenerate_ca,
  $deploy          = $::certs::params::deploy,
  $ca_common_name  = $::certs::params::ca_common_name,
  $country         = $::certs::params::country,
  $state           = $::certs::params::state,
  $city            = $::certs::params::city,
  $org             = $::certs::params::org,
  $org_unit        = $::certs::params::org_unit,

  $expiration      = $::certs::params::expiration,
  $ca_expiration   = $::certs::params::ca_expiration,

  $server_cert     = $::certs::params::server_cert,
  $server_key      = $::certs::params::server_key,
  $server_cert_req = $::certs::params::server_cert_req,
  $server_ca_cert  = $::certs::params::server_ca_cert,

  $pki_dir         = $::certs::params::pki_dir,
  $ssl_build_dir   = $::certs::params::ssl_build_dir,

  $user            = $::certs::params::user,
  $group           = $::certs::params::group,

  $default_ca_name = $::certs::params::default_ca_name,
  $server_ca_name  = $::certs::params::server_ca_name,
) inherits certs::params {

  if $server_cert {
    validate_absolute_path($server_cert)
    validate_absolute_path($server_cert_req)
    validate_absolute_path($server_key)
    validate_absolute_path($server_ca_cert)
    validate_file_exists($server_cert, $server_cert_req, $server_key, $server_ca_cert)
  }

  $nss_db_dir   = "${pki_dir}/nssdb"

  $ca_key = "${pki_dir}/private/${default_ca_name}.key"
  $ca_cert = "${pki_dir}/certs/${default_ca_name}.crt"
  $ca_cert_stripped = "${pki_dir}/certs/${default_ca_name}-stripped.crt"
  $ca_key_password = cache_data('foreman_cache_data', 'ca_key_password', random_password(24))
  $ca_key_password_file = "${pki_dir}/private/${default_ca_name}.pwd"

  $katello_server_ca_cert = "${pki_dir}/certs/${server_ca_name}.crt"
  $katello_default_ca_cert = "${pki_dir}/certs/${default_ca_name}.crt"

  class { '::certs::install': } ->
  class { '::certs::config': } ->
  class { '::certs::ca': }

  $default_ca = $::certs::ca::default_ca
  $server_ca = $::certs::ca::server_ca
}
