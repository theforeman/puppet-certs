# Certs Parameters
class certs::params {
  $pki_dir = '/etc/pki/katello'
  $node_fqdn = $facts['networking']['fqdn']

  $ca_common_name = $facts['networking']['fqdn']  # we need fqdn as CA common name as candlepin uses it as a ssl cert

  $cname = [] # Kafo cannot handle Array types as static parameters, https://projects.theforeman.org/issues/31565

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
}
