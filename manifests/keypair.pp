# @api private
define certs::keypair (
  $key_pair,
  $key_file,
  $cert_file,
  Enum['present', 'absent'] $ensure = 'present',
  $manage_key  = false,
  $key_owner   = undef,
  $key_group   = undef,
  $key_mode    = undef,
  $manage_cert = false,
  $cert_owner  = undef,
  $cert_group  = undef,
  $cert_mode   = undef,
  $unprotect   = false,
  $strip       = false,
  $password_file = undef,
) {
  $key_pair ~>
  privkey { $key_file:
    ensure        => $ensure,
    key_pair      => $key_pair,
    unprotect     => $unprotect,
    password_file => $password_file,
  } ~>
  pubkey { $cert_file:
    ensure   => $ensure,
    key_pair => $key_pair,
    strip    => $strip,
  }

  $file_ensure = bool2str($ensure == 'present', 'file', 'absent')

  if $manage_key {
    file { $key_file:
      ensure  => $file_ensure,
      owner   => $key_owner,
      group   => $key_group,
      mode    => $key_mode,
      require => Privkey[$key_file],
    }
  }

  if $manage_cert {
    file { $cert_file:
      ensure  => $file_ensure,
      owner   => $cert_owner,
      group   => $cert_group,
      mode    => $cert_mode,
      require => Pubkey[$cert_file],
    }
  }
}
