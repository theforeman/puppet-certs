# @summary Directory structure for certificates deployed into the pki_dir
# @api private
class certs::config::deploy (
  Stdlib::Absolutepath $pki_dir = $certs::pki_dir,
  String $group = $certs::group,
) {
  file { $pki_dir:
    ensure => directory,
    owner  => 'root',
    group  => $group,
    mode   => '0755',
  }

  file { "${pki_dir}/certs":
    ensure => directory,
    owner  => 'root',
    group  => $group,
    mode   => '0755',
  }

  file { "${pki_dir}/private":
    ensure => directory,
    owner  => 'root',
    group  => $group,
    mode   => '0750',
  }
}
