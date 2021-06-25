# Deploy a key pair
define certs::keypair (
  $key_pair,
  Stdlib::Absolutepath $key_file,
  Stdlib::Absolutepath $cert_file,
  Boolean $manage_key = false,
  Optional[String[1]] $key_owner = undef,
  Optional[String[1]] $key_group = undef,
  Optional[Stdlib::Filemode] $key_mode = undef,
  Boolean $manage_cert = false,
  Optional[String[1]] $cert_owner = undef,
  Optional[String[1]] $cert_group = undef,
  Optional[Stdlib::Filemode] $cert_mode = undef,
  Boolean $unprotect = false,
  Boolean $strip = false,
  Optional[Stdlib::Absolutepath] $password_file = undef,
) {
  $key_pair ~>
  privkey { $key_file:
    key_pair      => $key_pair,
    unprotect     => $unprotect,
    password_file => $password_file,
  } ~>
  pubkey { $cert_file:
    key_pair => $key_pair,
    strip    => $strip,
  }

  if $manage_key {
    file { $key_file:
      ensure  => file,
      owner   => $key_owner,
      group   => $key_group,
      mode    => $key_mode,
      require => Privkey[$key_file],
    }
  }

  if $manage_cert {
    file { $cert_file:
      ensure  => file,
      owner   => $cert_owner,
      group   => $cert_group,
      mode    => $cert_mode,
      require => Pubkey[$cert_file],
    }
  }
}
