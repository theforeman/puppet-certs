# @summary generate a certificate using the internal CA
#
# This ensures a certificate, key and CA exist.
class certs::certificate {
  include certs

  cert { $title:
    ensure        => present,
    hostname      => $certs::node_fqdn,
    cname         => $certs::cname,
    country       => $certs::country,
    state         => $certs::state,
    city          => $certs::city,
    org           => $certs::org,
    org_unit      => $certs::org_unit,
    expiration    => $certs::expiration,
    ca            => $certs::default_ca,
    generate      => $certs::generate,
    regenerate    => $certs::regenerate,
    deploy        => false,
    password_file => $ca_key_password_file,
    build_dir     => $certs::ssl_build_dir,
    require       => Class['certs'],
  }

  $certificate_file = "${certs::ssl_build_dir}/${hostname}/${hostname}.crt"
  $private_key_file = "${certs::ssl_build_dir}/${hostname}/${hostname}.key"
  $ca_file = $certs::katello_default_ca_cert
}
