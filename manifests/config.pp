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

  $candlepin_consumer_name = "${candlepin_cert_name}-consumer-${::fqdn}"
  $candlepin_consumer_summary = "Subscription-manager consumer certificate for Katello instance ${::fqdn}"
  $candlepin_consumer_description = 'Consumer certificate and post installation script that configures rhsm.'


}
