# Sets up nssdb
class certs::ssltools::nssdb (
  $nss_db_dir = $certs::nss_db_dir,
  $group = 'qpidd',
)  {
  Exec { logoutput => 'on_failure' }

  $nss_db_password_file   = "${nss_db_dir}/nss_db_password-file"

  $nssdb_files = $facts['os']['release']['major'] ? {
    '7' => ["${nss_db_dir}/cert8.db", "${nss_db_dir}/key3.db", "${nss_db_dir}/secmod.db"],
    default => ["${nss_db_dir}/cert9.db", "${nss_db_dir}/key4.db", "${nss_db_dir}/pkcs11.txt"]
  }

  ensure_packages(['openssl', 'nss-tools'])

  file { $nss_db_dir:
    ensure => directory,
    owner  => 'root',
    group  => $group,
    mode   => '0755',
  } ->
  exec { 'generate-nss-password':
    command => "openssl rand -base64 24 > ${nss_db_password_file}",
    path    => '/usr/bin',
    umask   => '0027',
    group   => $group,
    creates => $nss_db_password_file,
    require => Package['openssl'],
  } ->
  file { $nss_db_password_file:
    ensure => file,
    owner  => 'root',
    group  => $group,
    mode   => '0640',
  } ->
  exec { 'create-nss-db':
    command => "certutil -N -d '${nss_db_dir}' -f '${nss_db_password_file}'",
    path    => '/usr/bin',
    umask   => '0027',
    group   => $group,
    creates => $nssdb_files,
    require => Package['nss-tools'],
  } ->
  file { $nssdb_files:
    owner => 'root',
    group => $group,
    mode  => '0640',
  }
}
