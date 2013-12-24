# Certs Configuration
class certs::config {

  $candlepin_cert_name = 'candlepin-cert'

  $ssl_build_path = '/root/ssl-build'
  $ssl_tool_common = "--set-country '${certs::country}' --set-state '${certs::state}' --set-city '${certs::city}' --set-org-unit '${certs::org_unit}' --set-email '${certs::email}'"

  $katello_pub_cert_name = 'KATELLO-TRUSTED-SSL-CERT'
  $katello_private_key_name = 'KATELLO-PRIVATE-SSL-KEY'
  $katello_pub_cert = "/usr/share/katello/${katello_pub_cert_name}"
  $katello_private_key = "${ssl_build_path}/${katello_private_key_name}"

  $candlepin_pub_cert_name = "${candlepin_cert_name}.crt"
  $candlepin_private_key_name = "${candlepin_cert_name}.key"
  $candlepin_pub_cert = "/usr/share/katello/${candlepin_pub_cert_name}"
  $candlepin_private_key = "${ssl_build_path}/${candlepin_private_key_name}"
  $candlepin_certs_storage = '/etc/candlepin/certs'

  $candlepin_key_pair_name = "katello-${candlepin_cert_name}-key-pair"

  file { $certs::keystore_password_file:
    ensure  => file,
    content => $certs::keystore_password,
    mode    => '0644',
    owner   => 'tomcat',
    group   => $certs::user_groups,
    replace => false;
  }

  exec { 'generate-ssl-ca-password':
    command => "openssl rand -base64 24 > ${certs::ssl_ca_password_file}",
    path    => '/usr/bin',
    creates => $certs::ssl_ca_password_file
  }

  exec { 'generate-candlepin-ca-password':
    command => "openssl rand -base64 24 > ${certs::candlepin_ca_password_file}",
    path    => '/usr/bin',
    creates => $certs::candlepin_ca_password_file
  }

  file { $certs::ssl_ca_password_file:
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    require => Exec['generate-ssl-ca-password']
  }

  file { $certs::candlepin_ca_password_file:
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    require => Exec['generate-candlepin-ca-password']
  }

  file { $certs::pki_dir:
    ensure => directory,
    owner  => 'root',
    group  => $certs::user_groups,
    mode   => '0750',
  }
  exec { 'generate-ssl-keystore':
    command   => "openssl pkcs12 -export -in ${candlepin_certs_storage}/candlepin-ca.crt -inkey ${candlepin_certs_storage}/candlepin-ca.key -out ${certs::keystore} -name tomcat -CAfile ${candlepin_pub_cert} -caname root -password \"file:${certs::keystore_password_file}\" 2>>${certs::log_dir}/certificates.log",
    path      => '/usr/bin',
    creates   => $certs::keystore,
    notify    => Service[$certs::tomcat],
    require   => [File[$certs::pki_dir], Exec['deploy-candlepin-certificate-to-cp'], File[$certs::log_dir]]
  }

  file { $certs::keystore:
    owner   => 'root',
    group   => $certs::user_groups,
    mode    => '0640',
    require => [Exec['generate-ssl-keystore']]
  }

  file { $ssl_build_path:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0700'
  }

  file { "${ssl_build_path}/rhsm-katello-reconfigure":
    content => template('certs/rhsm-katello-reconfigure.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    require => File[$ssl_build_path]
  }

  exec { 'generate-candlepin-certificate':
    cwd     => '/root',
    command => "katello-ssl-tool --gen-ca -p \"$(cat ${certs::candlepin_ca_password_file})\" --set-country '${certs::country}' --set-state '${certs::state}' --set-city '${certs::city}' --set-org '${certs::org}' --set-org-unit '${certs::org_unit}' --set-common-name `hostname` --set-email '' --ca-key '${candlepin_cert_name}.key' --ca-cert '${candlepin_cert_name}.crt' --ca-cert-rpm  '${candlepin_key_pair_name}' 2>>${certs::log_dir}/certificates.log",
    path    => '/usr/bin:/bin',
    creates => "${ssl_build_path}/${candlepin_cert_name}.crt",
    require => [File[$certs::candlepin_ca_password_file], File[$certs::log_dir]],
    notify  => Exec['generate-candlepin-consumer-certificate'] # regenerate consumer RPM as well
  }

  exec { 'deploy-candlepin-certificate-to-cp':
    command => "openssl x509 -in ${candlepin_pub_cert} -out ${candlepin_certs_storage}/candlepin-ca.crt; openssl rsa -in ${candlepin_private_key} -out ${candlepin_certs_storage}/candlepin-ca.key -passin 'file:/etc/katello/candlepin_ca_password-file' 2>>${certs::log_dir}/certificates.log",
    path    => '/bin:/usr/bin',
    creates => ["${candlepin_certs_storage}/candlepin-ca.crt", "${candlepin_certs_storage}/candlepin-ca.key"],
    require => [Exec['deploy-candlepin-certificate'], File[$certs::log_dir]]
  } ->
  exec { 'install-ca-certificate':
    cwd     => '/etc/pki/tls/certs',
    command => "ln -s ${candlepin_certs_storage}/candlepin-ca.crt `openssl x509 -hash -noout -in ${candlepin_certs_storage}/candlepin-ca.crt`.0",
    unless  => "test -e `openssl x509 -hash -noout -in ${candlepin_certs_storage}/candlepin-ca.crt`.0",
    path    => '/usr/bin:/bin'
  }

  $candlepin_consumer_name = "${candlepin_cert_name}-consumer-${::fqdn}"
  $candlepin_consumer_summary = "Subscription-manager consumer certificate for Katello instance ${::fqdn}"
  $candlepin_consumer_description = 'Consumer certificate and post installation script that configures rhsm.'

  file { "${certs::candlepin_certs_dir}/candlepin-ca.key":
    owner   => 'root',
    group   => $certs::user_groups,
    mode    => '0640',
    require => Exec['deploy-candlepin-certificate-to-cp'],
    before  => Class['candlepin::service']
  }

  file { "${certs::candlepin_certs_dir}/candlepin-ca.crt":
    owner   => 'root',
    group   => $certs::user_groups,
    mode    => '0644',
    require => Exec['deploy-candlepin-certificate-to-cp'],
    before  => Class['candlepin::service']
  }

  $katello_www_pub_dir = '/var/www/html/pub'

  file { $katello_www_pub_dir:
    ensure => directory,
    owner  => 'apache',
    group  => 'apache',
    mode   => '0755',
  }

  exec { 'generate-candlepin-consumer-certificate':
    cwd       => $katello_www_pub_dir,
    command   => "gen-rpm.sh --name '${candlepin_consumer_name}' --version 1.0 --release 1 --packager None --vendor None --group 'Applications/System' --summary '${candlepin_consumer_summary}' --description '${candlepin_consumer_description}' --requires subscription-manager --post ${ssl_build_path}/rhsm-katello-reconfigure /etc/rhsm/ca/candlepin-local.pem:644=${ssl_build_path}/${candlepin_cert_name}.crt 2>>${certs::log_dir}/certificates.log && /sbin/restorecon ./*rpm",
    path      => '/usr/share/katello/certs:/usr/bin:/bin',
    creates   => "${katello_www_pub_dir}/${candlepin_consumer_name}-1.0-1.noarch.rpm",
    require   => [Exec['generate-candlepin-certificate'], File["${ssl_build_path}/rhsm-katello-reconfigure"], File[$certs::log_dir]]
  }

  file { "${katello_www_pub_dir}/${candlepin_cert_name}-consumer-latest.noarch.rpm":
    ensure  => 'link',
    target  => "${katello_www_pub_dir}/${candlepin_consumer_name}-1.0-1.noarch.rpm",
    require => Exec['generate-candlepin-certificate']
  }

  exec { 'deploy-candlepin-certificate':
    command => "rpm -qp /root/ssl-build/$(grep ${candlepin_cert_name}.*noarch.rpm /root/ssl-build/latest.txt) | xargs rpm -q; if [ $? -ne 0 ]; then rpm -Uvh --force /root/ssl-build/$(grep noarch.rpm /root/ssl-build/latest.txt); fi",
    path    => '/bin:/usr/bin',
    creates => $candlepin_pub_cert,
    require => [File["${katello_www_pub_dir}/${candlepin_cert_name}-consumer-latest.noarch.rpm"]]
  }

}
