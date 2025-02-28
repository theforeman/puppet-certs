# @summary Basic directory structure for certificate generation
# @api private
class certs::config::generate (
) {
  file { $certs::ssl_build_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  }
}
