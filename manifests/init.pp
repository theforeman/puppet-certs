# == Class: certs
#
# Install and configure certs
#
# === Parameters:
#
# $oauth_key::              The oauth key for talking to the candlepin API;
#
class certs (

  $log_dir = $certs::params::log_dir,
  $tomcat = $certs::params::tomcat,

  $node_fqdn      = $fqdn,
  $generate       = true,
  $regenerate     = false,
  $regenerate_ca  = false,
  $deploy         = false,
  $ca_common_name    = $certs::params::ca_common_name,
  $country        = $certs::params::country,
  $state          = $certs::params::state,
  $city           = $certs::params::sity,
  $org            = $certs::params::org,
  $org_unit       = $certs::params::org_unit,

  $expiration     = $certs::params::expiration,
  $ca_expiration     = $certs::params::ca_expiration,

  $user_groups = $certs::params::user_groups,

  $pki_dir = $certs::params::pki_dir,
  $keystore = $certs::params::keystore,
  $keystore_password_file = $certs::params::keystore_password_file,
  $keystore_password = $certs::params::keystore_password,

  $candlepin_certs_dir = $certs::params::candlepin_certs_dir,
  $candlepin_ca_password_file = $certs::params::candlepin_ca_password_file,
  $ssl_ca_password_file = $certs::params::ssl_ca_password_file,

  $nss_db_password_file = $certs::params::nss_db_password_file,
  $ssl_pk12_password_file = $certs::params::ssl_pk12_password_file,

  ) inherits certs::params {

  class { 'certs::install': }

  $default_ca = Ca['candlepin-ca']

  ca { 'candlepin-ca':
    ensure      => present,
    common_name => $certs::ca_common_name,
    country     => $certs::country,
    state       => $certs::state,
    city        => $certs::city,
    org         => $certs::org,
    org_unit    => $certs::org_unit,
    expiration  => $certs::ca_expiration,
    generate    => $certs::generate,
    regenerate  => $certs::regenerate_ca,
    deploy      => true,
  }

}
