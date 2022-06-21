# @summary Deploy a certificate and its matching key
# @api private
define certs::keypair (
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
  Boolean $key_decrypt = false,
  Optional[Stdlib::Absolutepath] $key_password_file = undef,
) {
  private_key { $key_file:
    ensure        => $key_ensure,
    source        => "${source_dir}/${title}.key",
    decrypt       => $key_decrypt,
    password_file => $key_password_file,
    owner         => $key_owner,
    group         => $key_group,
    mode          => $key_mode,
  }

  file { $cert_file:
    ensure => $cert_ensure,
    source => "${source_dir}/${title}.crt",
    owner  => $cert_owner,
    group  => $cert_group,
    mode   => $cert_mode,
  }
}
