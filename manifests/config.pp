# @summary Basic directory structure
# @api private
class certs::config (
  Stdlib::Absolutepath $pki_dir = $certs::pki_dir,
  String $group = $certs::group,
) {
  file { $certs::ssl_build_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  }

  if $certs::deploy {
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
}
