# @summary Deploy a certificate and its matching key
# @api private
define certs::key_pair (
  Stdlib::Absolutepath $source_dir,
  Stdlib::Absolutepath $key_file,
  Stdlib::Absolutepath $cert_file,
  Enum['present', 'absent'] $key_ensure = 'present',
  String $key_owner = 'root',
  String $key_group = undef,
  Stdlib::Filemode $key_mode = '440',
  Enum['present', 'absent'] $cert_ensure = 'present',
  String $cert_owner = 'root',
  String $cert_group = undef,
  Stdlib::Filemode $cert_mode = '440',
) {

  file { $key_file:
    ensure    => $key_ensure,
    source    => "${source_dir}/${title}.key",
    owner     => $key_owner,
    group     => $key_group,
    mode      => $key_mode,
    show_diff => false,
  }

  file { $cert_file:
    ensure => $cert_ensure,
    source => "${source_dir}/${title}.crt",
    owner  => $cert_owner,
    group  => $cert_group,
    mode   => $cert_mode,
  }

}
