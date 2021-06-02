define certs::key_pair (
  $source_dir,
  $key_file,
  $cert_file,
  $key_owner   = undef,
  $key_group   = undef,
  $key_mode    = undef,
  $cert_owner  = undef,
  $cert_group  = undef,
  $cert_mode   = undef,
  $require     = undef,
) {

  file { $key_file:
    ensure  => file,
    source  => "${source_dir}/${title}.key",
    owner   => $key_owner,
    group   => $key_group,
    mode    => $key_mode,
    require => $require,
  }

  file { $cert_file:
    ensure  => file,
    source  => "${source_dir}/${title}.crt",
    owner   => $cert_owner,
    group   => $cert_group,
    mode    => $cert_mode,
    require => $require,
  }

}
