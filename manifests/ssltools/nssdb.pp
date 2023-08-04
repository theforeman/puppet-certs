# Sets up nssdb
class certs::ssltools::nssdb (
  Stdlib::Absolutepath $nss_db_dir = "${certs::pki_dir}/nssdb",
  Stdlib::Absolutepath $nss_db_password_file = "${certs::pki_dir}/nss_db_password-file",
  String[10] $nss_db_password = extlib::cache_data('foreman_cache_data', 'certs-nss-db-password', extlib::random_password(32)),
  String[1] $group = 'qpidd',
) {
  stdlib::ensure_packages(['nss-tools'])

  file { $nss_db_password_file:
    ensure    => file,
    content   => $nss_db_password,
    show_diff => false,
    owner     => 'root',
    group     => $group,
    mode      => '0640',
  }

  nssdb { $nss_db_dir:
    ensure        => present,
    password_file => $nss_db_password_file,
    owner         => 'root',
    group         => $group,
    mode          => '0640',
  }
}
