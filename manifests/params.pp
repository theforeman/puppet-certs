# Certs Parameters
class certs::params {

  if file_exists('/usr/sbin/tomcat') and file_exists('/usr/sbin/tomcat6') {
    $tomcat = 'tomcat'
  }
  else {
    $tomcat = 'tomcat6'
  }

  $log_dir = '/var/log/certs'

  $node_fqdn = $::fqdn

  $ca_common_name = $::fqdn  # we need fqdn as CA common name as candlepin uses it as a ssl cert

  $generate      = true
  $regenerate    = false
  $regenerate_ca = false
  $deploy        = true

  $country = 'US'
  $state   = 'North Carolina'
  $city    = 'Raleigh'
  $org     = 'SomeOrg'
  $org_unit = 'SomeOrgUnit'
  $expiration = '365'
  $ca_expiration = '36500'

  $ssl_ca_password_file = '/etc/katello/ssl_ca_password-file'
  $candlepin_ca_password_file = '/etc/katello/candlepin_ca_password-file'

  # main keystore location
  $pki_dir = '/etc/pki/katello'
  $keystore = "${pki_dir}/keystore"
  $keystore_password_file = '/etc/katello/keystore_password-file'
  $keystore_password = find_or_create_password($keystore_password_file)

  $nss_db_password_file = '/etc/katello/nss_db_password-file'
  $nss_db_dir = '/etc/pki/katello/nssdb'
  $ssl_pk12_password_file = '/etc/katello/pk12_password-file'

  $candlepin_certs_dir = '/etc/candlepin/certs'

  $user_groups = 'foreman'
}
