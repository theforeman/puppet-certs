# Certs Configuration for Pulp
class certs::config::pulp {
  include pulp::service
  include qpid::service

  exec { 'generate-ssl-qpid-broker-certificate':
    cwd     => '/root',
    path    => '/usr/bin:/bin',
    command => "katello-ssl-tool --gen-server -p \"$(cat ${certs::candlepin_ca_password_file})\" --ca-cert '${candlepin_pub_cert}' --ca-key '${candlepin_private_key}' ${ssl_tool_common} --cert-expiration '${certs::expiration}' --set-org 'pulp' --server-cert '${qpid_cert_name}.crt' --server-cert-req '${qpid_cert_name}.req' --set-email '' --server-key '${qpid_cert_name}.key' --server-tar 'katello-${qpid_cert_name}-key-pair' --server-rpm 'katello-${qpid_cert_name}-key-pair' 2>>${certs::log_dir}/certificates.log",
    creates => "${ssl_build_path}/${::fqdn}/${qpid_cert_name}.crt",
    require => [File[$certs::candlepin_ca_password_file], Exec['deploy-candlepin-certificate'], File[$certs::log_dir]]
  }

  exec { 'deploy-ssl-qpid-broker-certificate':
    path    => '/bin:/usr/bin',
    command => "rpm -qp /root/ssl-build/${::fqdn}/$(grep noarch.rpm /root/ssl-build/${::fqdn}/latest.txt) | xargs rpm -q; if [ $? -ne 0 ]; then rpm -Uvh --force /root/ssl-build/${::fqdn}/$(grep ${qpid_cert_name}.*noarch.rpm /root/ssl-build/${::fqdn}/latest.txt); fi",
    creates => "/etc/pki/tls/certs/${qpid_cert_name}.crt",
    require => Exec['generate-ssl-qpid-broker-certificate'],
  }

  file { $certs::nss_db_password_file:
    owner   => 'root',
    group   => $certs::user_groups,
    mode    => '0640',
    require => Exec['generate-nss-password']
  }

  exec { 'generate-pk12-password':
    path    => '/usr/bin',
    command => "openssl rand -base64 24 > ${certs::ssl_pk12_password_file}",
    creates => $certs::ssl_pk12_password_file
  }

  file { $certs::ssl_pk12_password_file:
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    require => Exec['generate-pk12-password']
  }

  file { $nss_db_dir:
    ensure => directory,
    owner  => 'root',
    group  => $certs::user_groups,
    mode   => '0744',
  }

  file { ["${nss_db_dir}/cert8.db", "${nss_db_dir}/key3.db", "${nss_db_dir}/secmod.db"]:
    owner   => 'root',
    group   => $certs::user_groups,
    mode    => '0640',
    require => Exec['create-nss-db'],
    before  => Class['qpid::service']
  }

  exec { 'create-nss-db':
    command => "certutil -N -d '${nss_db_dir}' -f '${certs::nss_db_password_file}' 2>>${certs::log_dir}/certificates.log",
    path    => '/usr/bin',
    require => [
      File[$certs::nss_db_password_file],
      File[$nss_db_dir],
      Exec['deploy-ssl-qpid-broker-certificate'],
      File[$certs::log_dir]
      ],
    before  => Class['qpid::service'],
    creates => ["${nss_db_dir}/cert8.db", "${nss_db_dir}/key3.db", "${nss_db_dir}/secmod.db"],
    notify  => [
      Exec['add-candlepin-cert-to-nss-db'],
      Exec['add-broker-cert-to-nss-db'],
      Exec['generate-pfx-for-nss-db'],
      Exec['add-private-key-to-nss-db'],
      Service['qpidd'],
    ];
  }

  # qpid client certificates
  exec { 'generate-ssl-qpid-client-certificate':
    cwd       => '/root',
    command   => "katello-ssl-tool --gen-server -p \"$(cat ${certs::candlepin_ca_password_file})\" --ca-cert '${candlepin_pub_cert}' --ca-key '${candlepin_private_key}' ${ssl_tool_common} --cert-expiration '${certs::expiration}' --set-org 'pulp' --server-cert '${qpid_client_cert_name}.crt' --server-cert-req '${qpid_client_cert_name}.req' --set-email '' --server-key '${qpid_client_cert_name}.key' --server-tar 'katello-${qpid_client_cert_name}-key-pair' --server-rpm 'katello-${qpid_client_cert_name}-key-pair' 2>>${certs::log_dir}/certificates.log",
    path      => '/usr/bin:/bin/',
    creates   => "${ssl_build_path}/${::fqdn}/${qpid_client_cert_name}.crt",
    require   => [Exec['deploy-candlepin-certificate'], File[$certs::log_dir], Exec['deploy-ssl-qpid-broker-certificate']]
  }

  exec { 'deploy-ssl-qpid-client-certificate':
    command   => "rpm -qp ${ssl_build_path}/${::fqdn}/$(grep noarch.rpm ${ssl_build_path}/${::fqdn}/latest.txt) | xargs rpm -q; if [ $? -ne 0 ]; then rpm -Uvh --force ${ssl_build_path}/${::fqdn}/$(grep ${qpid_client_cert_name}.*noarch.rpm ${ssl_build_path}/${::fqdn}/latest.txt); fi",
    path      => '/bin:/usr/bin',
    creates   => "/etc/pki/tls/certs/${qpid_client_cert_name}.crt",
    require   => Exec['generate-ssl-qpid-client-certificate'],
    before    => Class['pulp::service']
  }

  # prepare certificate for pulp server
  exec { 'strip-qpid-client-certificate':
    command => "cp ${ssl_build_path}/${::fqdn}/qpid-client.key /etc/pki/pulp/qpid_client_striped.crt; openssl x509 -in ${ssl_build_path}/${::fqdn}/qpid-client.crt >> /etc/pki/pulp/qpid_client_striped.crt 2>>${certs::log_dir}/certificates.log",
    path    => '/bin:/usr/bin',
    creates => '/etc/pki/pulp/qpid_client_striped.crt',
    require => [Exec['deploy-ssl-qpid-client-certificate'], File[$certs::log_dir]],
    notify  => Exec['reload-apache'],
    before  => Class['pulp::service']
  }

  file { '/etc/pki/pulp/qpid_client_striped.crt':
    owner   => 'apache',
    group   => 'apache',
    mode    => '0640',
    require => Exec['strip-qpid-client-certificate']
  }

}
