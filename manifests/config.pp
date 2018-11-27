# Certs Configuration
class certs::config (
  $pki_dir = $::certs::pki_dir,
  $group   = $::certs::group,
) {

  file { $pki_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { "${pki_dir}/certs":
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { "${pki_dir}/private":
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0750',
  }

}
