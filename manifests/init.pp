# == Class: certs
#
# Base for installing and configuring certs. It holds the basic configuration
# around certificates generation and deployment. The per-subsystem configuration
# of certificates should go into `subsystem_module/manifests/certs.pp`.
#
# === Parameters:
#
# $node_fqdn::            The fqdn of the host the generated certificates
#                         should be for
#
# $cname::                The alternative names of the host the generated certificates
#                         should be for
#
# $server_ca_cert::       Path to the CA that issued the ssl certificates for https
#                         if not specified, the default CA will be used
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
# $tar_file::             Use a tarball with certificates rather than generate
#                         new ones. This can be used on another node which is
#                         not the CA.
#
# === Advanced parameters:
#
# $log_dir::              Where the log files should go
#
# $generate::             Should the generation of the certs be part of the
#                         configuration
#
# $regenerate::           Force regeneration of the certificates (excluding
#                         CA certificates)
#
# $regenerate_ca::        Force regeneration of the CA certificate
#
# $deploy::               Deploy the certs on the configured system. False means
#                         we want to apply it to a different system
#
# $ca_common_name::       Common name for the generated CA certificate
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
# $ca_expiration::        CA expiration attribute for managed certificates
#
# $pki_dir::              The PKI directory under which to place certs
#
# $ssl_build_dir::        The directory where SSL keys, certs and RPMs will be generated
#
# $user::                 The system user name who should own the certs
#
# $group::                The group who should own the certs
#
# $default_ca_name::      The name of the default CA
#
# $server_ca_name::       The name of the server CA (used for https)
#
# $repomd_gpg::                  Path to a directory containing a keyring to use
#                                for repository metadata signing
#                                If not specified, a GPG key will be generated
#
# $repomd_gpg_name::             Name attribute for the GPG key generated for
#                                repository metadata signing
#
# $repomd_gpg_comment::          Comment attribute for the GPG key generated
#                                for repository metadata signing
#
# $repomd_gpg_email::            Email attribute for the GPG key generated for
#                                repository metadata signing
#
# $repomd_gpg_key_type::         OpenPGP algorithm number or name for the GPG
#                                key generated for repository metadata signing
#
# $repomd_gpg_key_length::       Length of the GPG key generated for repository
#                                metadata signing
#
# $repomd_gpg_expire_date::      Expiration date of the GPG key generated for
#                                repository metadata signing
#
# $repomd_gpg_use_subkeys::      Should a GPG subkey be generated for each host
#                                Note that yum does not currently support
#                                subkeys
#
# $repomd_gpg_sub::              Path to a directory containing a subkey keyring
#                                to use for repository metadata signing
#                                If not specified, a GPG subkey will be
#                                generated
#
# $repomd_gpg_sub_key_type::     Input value for the interactive gpg key type
#                                prompt for the GPG subkey generated for
#                                repository metadata signing
#
# $repomd_gpg_sub_key_length::   Length of the GPG subkey generated for
#                                repository metadata signing
#
# $repomd_gpg_sub_expire_date::  Expiration date of the GPG subkey generated for
#                                repository metadata signing
#
# $repomd_gpg_dir::              The directory where the GPG key for repository
#                                metadata signing will be deployed
#
# $repomd_gpg_user::             The user who should own the deployed GPG key
#                                for repository metadata signing
#
# $repomd_gpg_group::            The group who should own the deployed GPG key
#                                for repository metadata signing
#
# $repomd_gpg_pub_file::         Filename for the deployed public GPG key
#
class certs (
  Stdlib::Absolutepath $log_dir = $certs::params::log_dir,
  Stdlib::Fqdn $node_fqdn = $certs::params::node_fqdn,
  Array[Stdlib::Fqdn] $cname = $certs::params::cname,
  Boolean $generate = $certs::params::generate,
  Boolean $regenerate = $certs::params::regenerate,
  Boolean $regenerate_ca = $certs::params::regenerate_ca,
  Boolean $deploy = $certs::params::deploy,
  String $ca_common_name = $certs::params::ca_common_name,
  String[2,2] $country = $certs::params::country,
  String $state = $certs::params::state,
  String $city = $certs::params::city,
  String $org = $certs::params::org,
  String $org_unit = $certs::params::org_unit,
  String $expiration = $certs::params::expiration,
  String $ca_expiration = $certs::params::ca_expiration,
  Optional[Stdlib::Absolutepath] $server_cert = $certs::params::server_cert,
  Optional[Stdlib::Absolutepath] $server_key = $certs::params::server_key,
  Optional[Stdlib::Absolutepath] $server_cert_req = $certs::params::server_cert_req,
  Optional[Stdlib::Absolutepath] $server_ca_cert = $certs::params::server_ca_cert,
  Stdlib::Absolutepath $pki_dir = $certs::params::pki_dir,
  Stdlib::Absolutepath $ssl_build_dir = $certs::params::ssl_build_dir,
  String $user = $certs::params::user,
  String $group = $certs::params::group,
  String $default_ca_name = $certs::params::default_ca_name,
  String $server_ca_name = $certs::params::server_ca_name,
  Optional[Stdlib::Absolutepath] $tar_file = $certs::params::tar_file,
  Optional[Stdlib::Absolutepath] $repomd_gpg = $certs::params::repomd_gpg,
  Optional[String] $repomd_gpg_name = $certs::params::repomd_gpg_name,
  Optional[String] $repomd_gpg_comment = $certs::params::repomd_gpg_comment,
  Optional[String] $repomd_gpg_email = $certs::params::repomd_gpg_email,
  String $repomd_gpg_key_type = $certs::params::repomd_gpg_key_type,
  String $repomd_gpg_key_length = $certs::params::repomd_gpg_key_length,
  String $repomd_gpg_expire_date = $certs::params::repomd_gpg_expire_date,
  Boolean $repomd_gpg_use_subkeys = $certs::params::repomd_gpg_use_subkeys,
  Optional[Stdlib::Absolutepath] $repomd_gpg_sub = $certs::params::repomd_gpg_sub,
  String $repomd_gpg_sub_key_type = $certs::params::repomd_gpg_sub_key_type,
  String $repomd_gpg_sub_key_length = $certs::params::repomd_gpg_sub_key_length,
  String $repomd_gpg_sub_expire_date = $certs::params::repomd_gpg_sub_expire_date,
  Stdlib::Absolutepath $repomd_gpg_dir = $certs::params::repomd_gpg_dir,
  String $repomd_gpg_user = $certs::params::repomd_gpg_user,
  String $repomd_gpg_group = $certs::params::repomd_gpg_group,
  String $repomd_gpg_pub_file = $certs::params::repomd_gpg_pub_file,
) inherits certs::params {

  if $server_cert {
    validate_file_exists($server_cert, $server_key, $server_ca_cert)
    if $server_cert_req {
      validate_file_exists($server_cert_req)
    }
  }

  $nss_db_dir   = "${pki_dir}/nssdb"

  $ca_key = "${pki_dir}/private/${default_ca_name}.key"
  $ca_cert = "${pki_dir}/certs/${default_ca_name}.crt"
  $ca_cert_stripped = "${pki_dir}/certs/${default_ca_name}-stripped.crt"
  $ca_key_password = extlib::cache_data('foreman_cache_data', 'ca_key_password', extlib::random_password(24))
  $ca_key_password_file = "${pki_dir}/private/${default_ca_name}.pwd"

  $katello_server_ca_cert = "${pki_dir}/certs/${server_ca_name}.crt"
  $katello_default_ca_cert = "${pki_dir}/certs/${default_ca_name}.crt"

  if $tar_file {
    certs::tar_extract { $tar_file:
      before => Class['certs::install'],
    }
  }

  contain certs::install
  contain certs::config
  contain certs::ca

  Class['certs::install'] ->
  Class['certs::config'] ->
  Class['certs::ca']

  $default_ca = $certs::ca::default_ca
  $server_ca = $certs::ca::server_ca
}
