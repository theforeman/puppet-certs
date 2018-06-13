# == Class: certs::katello
#
# This class builds an RPM containing the bootstrap for a candlepin consumer.
# This file is placed in $katello_www_pub_dir.
#
class certs::katello (
  $hostname                          = $certs::node_fqdn,
  $deployment_url                    = undef,
  $rhsm_port                         = 443,
  $rhsm_ca_dir                       = '/etc/rhsm/ca',
  $candlepin_cert_rpm_alias_filename = 'katello-ca-consumer-latest.noarch.rpm',
  $katello_www_pub_dir               = '/var/www/html/pub',
  $katello_server_ca_cert            = $certs::katello_server_ca_cert,
  $server_ca_name                    = $certs::server_ca_name,
  $ca_cert                           = $certs::ca_cert,
  $server_ca                         = $certs::server_ca,
  $include_repomd_gpg                = false,
  $repomd_pub_gpg                    = "${certs::repomd_gpg_dir}/${certs::repomd_gpg_pub_file}",
) inherits certs {
  $katello_rhsm_setup_script      = 'katello-rhsm-consumer'
  $katello_rhsm_setup_script_location = "/usr/bin/${katello_rhsm_setup_script}"

  $candlepin_consumer_name        = "katello-ca-consumer-${hostname}"
  $candlepin_consumer_summary     = "Subscription-manager consumer certificate for Katello instance ${hostname}"
  $candlepin_consumer_description = 'Consumer certificate and post installation script that configures rhsm.'

  include trusted_ca
  trusted_ca::ca { 'katello_server-host-cert':
    source  => $katello_server_ca_cert,
    require => File[$katello_server_ca_cert],
  }

  file { $katello_www_pub_dir:
    ensure => directory,
    owner  => 'apache',
    group  => 'apache',
    mode   => '0755',
  } ->
  # Placing the CA in the pub dir for trusting by a user in their browser
  file { "${katello_www_pub_dir}/${server_ca_name}.crt":
    ensure  => file,
    source  => $katello_server_ca_cert,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File[$katello_server_ca_cert],
  } ~>
  certs::rhsm_reconfigure_script { "${katello_www_pub_dir}/${katello_rhsm_setup_script}":
    ca_cert            => $ca_cert,
    server_ca_cert     => $katello_server_ca_cert,
    include_repomd_gpg => $include_repomd_gpg,
    repomd_pub_gpg     => $repomd_pub_gpg,
  } ~>
  certs_bootstrap_rpm { $candlepin_consumer_name:
    dir              => $katello_www_pub_dir,
    summary          => $candlepin_consumer_summary,
    description      => $candlepin_consumer_description,
    # katello-default-ca is needed for the katello-agent to work properly
    # (especially in the custom certs scenario)
    files            => ["${katello_rhsm_setup_script_location}:755=${katello_www_pub_dir}/${katello_rhsm_setup_script}"],
    bootstrap_script => "/bin/bash ${katello_rhsm_setup_script_location}",
    postun_script    => 'test -f /etc/rhsm/rhsm.conf.kat-backup && command cp /etc/rhsm/rhsm.conf.kat-backup /etc/rhsm/rhsm.conf',
    alias            => $candlepin_cert_rpm_alias_filename,
    subscribe        => $server_ca,
  }
}
