# Certs Parameters
class certs::params {

  $pki_dir = '/etc/pki/katello'
  $node_fqdn = $facts['networking']['fqdn']

  $ca_common_name = $facts['networking']['fqdn']  # we need fqdn as CA common name as candlepin uses it as a ssl cert

  $keystore_password_file = 'keystore_password-file'
  $truststore_password_file = 'truststore_password-file'

  $foreman_proxy_cert    = '/etc/foreman-proxy/ssl_cert.pem'
  $foreman_proxy_key     = '/etc/foreman-proxy/ssl_key.pem'
  # for verifying the foreman client certs at the proxy side
  $foreman_proxy_ca_cert = '/etc/foreman-proxy/ssl_ca.pem'

  $foreman_proxy_foreman_ssl_cert    = '/etc/foreman-proxy/foreman_ssl_cert.pem'
  $foreman_proxy_foreman_ssl_key     = '/etc/foreman-proxy/foreman_ssl_key.pem'
  # for verifying the foreman https
  $foreman_proxy_foreman_ssl_ca_cert = '/etc/foreman-proxy/foreman_ssl_ca.pem'

  $puppet_client_cert = "${pki_dir}/puppet/puppet_client.crt"
  $puppet_client_key  = "${pki_dir}/puppet/puppet_client.key"
  # for verifying the foreman https
  $puppet_ssl_ca_cert = "${pki_dir}/puppet/puppet_client_ca.crt"

  $candlepin_certs_dir              = '/etc/candlepin/certs'
  $candlepin_keystore               = "${candlepin_certs_dir}/keystore"
  $candlepin_truststore             = "${candlepin_certs_dir}/truststore"
  $candlepin_ca_cert                = "${candlepin_certs_dir}/candlepin-ca.crt"
  $candlepin_ca_key                 = "${candlepin_certs_dir}/candlepin-ca.key"

  $pulp_pki_dir = '/etc/pki/pulp'

  $qpid_client_cert = "${pulp_pki_dir}/qpid/client.crt"
  $qpid_client_ca_cert = "${pulp_pki_dir}/qpid/ca.crt"

  $qpid_router_server_cert = "${pki_dir}/qpid_router_server.crt"
  $qpid_router_client_cert = "${pki_dir}/qpid_router_client.crt"
  $qpid_router_server_key  = "${pki_dir}/qpid_router_server.key"
  $qpid_router_client_key  = "${pki_dir}/qpid_router_client.key"
  $qpid_router_owner       = 'qdrouterd'
  $qpid_router_group       = 'root'

  $qpidd_group = 'qpidd'
}
