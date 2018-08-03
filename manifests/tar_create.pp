# Define: certs::tar_create
#
# This define creates a tar ball of generated SSL certs
#
# === Parameters
#
# $path::            The $path of files to tar
#
# $sub_dir::         Sub-directory to get certificates RPMs from
#
define certs::tar_create(
  $path    = $title,
  $sub_dir = undef,
) {
  exec { "generate ${path}":
    cwd     => '/root',
    path    => ['/usr/bin', '/bin'],
    command => "tar -czf ${path} ssl-build/*.noarch.rpm ssl-build/${sub_dir}/*.noarch.rpm",
  }
}
