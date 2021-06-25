# Deploy a key pair
define certs::keypair (
  $key_pair,
  Stdlib::Absolutepath $key_file,
  Stdlib::Absolutepath $cert_file,
  Boolean $manage_key = false,
  Enum['present', 'absent'] $ensure_key  = 'present',
  Optional[String[1]] $key_owner = undef,
  Optional[String[1]] $key_group = undef,
  Optional[Stdlib::Filemode] $key_mode = undef,
  Boolean $manage_cert = false,
  Enum['present', 'absent'] $ensure_cert = 'present',
  Optional[String[1]] $cert_owner = undef,
  Optional[String[1]] $cert_group = undef,
  Optional[Stdlib::Filemode] $cert_mode = undef,
  Boolean $unprotect = false,
  Boolean $strip = false,
  Optional[Stdlib::Absolutepath] $password_file = undef,
) {
  privkey { $key_file:
    ensure        => $ensure_key,
    key_pair      => $key_pair,
    unprotect     => $unprotect,
    password_file => $password_file,
    subscribe     => $key_pair,
  }

  pubkey { $cert_file:
    ensure    => $ensure_cert,
    key_pair  => $key_pair,
    strip     => $strip,
    subscribe => Privkey[$key_file],
  }

  if $manage_key {
    file { $key_file:
      ensure  => $ensure_key,
      owner   => $key_owner,
      group   => $key_group,
      mode    => $key_mode,
      require => Privkey[$key_file],
    }
  }

  if $manage_cert {
    file { $cert_file:
      ensure  => $ensure_cert,
      owner   => $cert_owner,
      group   => $cert_group,
      mode    => $cert_mode,
      require => Pubkey[$cert_file],
    }
  }
}
