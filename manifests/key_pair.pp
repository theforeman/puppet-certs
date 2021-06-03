define certs::key_pair (
  Stdlib::Absolutepath $key_destination,
  Stdlib::Absolutepath $cert_destination,
  Enum['file', 'absent'] $ensure = 'file',
  Optional[Stdlib::Absolutepath] $key_source = undef,
  Optional[Stdlib::Absolutepath] $cert_source = undef,
  Stdlib::Filemode $key_mode = '0640',
  String[1] $key_owner = 'root',
  String[1] $key_group = 'root',
  Stdlib::Filemode $cert_mode = '0644',
  String[1] $cert_owner = 'root',
  String[1] $cert_group = 'root',
) {
  if $ensure == 'file' {
    assert_type(NotUndef, $key_source)
    assert_type(NotUndef, $cert_source)
  }

  file { $key_destination:
    ensure => $ensure,
    source => $key_source,
    owner  => $key_owner,
    group  => $key_group,
    mode   => $key_mode,
  }

  file { $cert_destination:
    ensure => $ensure,
    source => $cert_source,
    owner  => $cert_owner,
    group  => $cert_group,
    mode   => $cert_mode,
  }
}
