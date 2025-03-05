# @summary This class extracts a tarball
# @api private
# Parameters:
# - The $path of the tarball to extract
#
class certs::tar_extract (
  Stdlib::Absolutepath $path,
) {
  validate_file_exists($path)

  exec { "extract ${path}":
    cwd     => '/root',
    path    => ['/usr/bin', '/bin'],
    command => "tar -xaf ${path}",
  }
}
