# == Class: certs
# Sets up the GPG key for Pulp repository metadata signing
class certs::repomd_gpg (
  $generate                = $certs::generate,
  $regenerate              = $certs::regenerate,
  $regenerate_ca           = $certs::regenerate_ca,
  $deploy                  = $certs::deploy,
  $hostname                = $certs::node_fqdn,
  $build_dir               = $certs::ssl_build_dir,
  $existing_gpg            = $certs::repomd_gpg,
  $gpg_name                = $certs::repomd_gpg_name,
  $gpg_comment             = $certs::repomd_gpg_comment,
  $gpg_email               = $certs::repomd_gpg_email,
  $gpg_key_type            = $certs::repomd_gpg_key_type,
  $gpg_key_length          = $certs::repomd_gpg_key_length,
  $gpg_expire_date         = $certs::repomd_gpg_expire_date,
  $subkey                  = $certs::repomd_gpg_use_subkeys,
  $existing_sub            = $certs::repomd_gpg_sub,
  $sub_key_type            = $certs::repomd_gpg_sub_key_type,
  $sub_key_length          = $certs::repomd_gpg_sub_key_length,
  $sub_expire_date         = $certs::repomd_gpg_sub_expire_date,
  $deploy_gpg              = $certs::repomd_gpg_dir,
  $deploy_user             = $certs::repomd_gpg_user,
  $deploy_group            = $certs::repomd_gpg_group,
  $deploy_pub_file         = $certs::repomd_gpg_pub_file,
) {

  package { 'gnupg2':
    ensure  => installed,
  }

  gpg { 'repomd_gpg':
    ensure          => present,
    generate        => $generate,
    regenerate      => $regenerate,
    regenerate_ca   => $regenerate_ca,
    deploy          => $deploy,
    hostname        => $hostname,
    build_dir       => $build_dir,
    existing_gpg    => $existing_gpg,
    gpg_name        => $gpg_name,
    gpg_comment     => $gpg_comment,
    gpg_email       => $gpg_email,
    gpg_key_type    => $gpg_key_type,
    gpg_key_length  => $gpg_key_length,
    gpg_expire_date => $gpg_expire_date,
    subkey          => $subkey,
    existing_sub    => $existing_sub,
    sub_key_type    => $sub_key_type,
    sub_key_length  => $sub_key_length,
    sub_expire_date => $sub_expire_date,
    deploy_gpg      => $deploy_gpg,
    deploy_user     => $deploy_user,
    deploy_group    => $deploy_group,
    deploy_pub_file => $deploy_pub_file,
  }

}
