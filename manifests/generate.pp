# Handles generating certificates
#
# === Parameters:
#
# $apache::   Generates certificates needed by Apache
#
# $foreman::   Generates certificates needed by Foreman
#
# $candlepin::   Generates certificates needed by Candlepin
#
# $foreman_proxy::   Generates certificates needed by Foreman Proxy
#
# $puppet::   Generates certificates needed by Puppet
#
class certs::generate (
  Boolean $apache = false,
  Boolean $foreman = false,
  Boolean $candlepin = false,
  Boolean $foreman_proxy = false,
  Boolean $puppet = false,
) {
  if $certs::generate::apache {
    include certs::apache
  }

  if $certs::generate::foreman {
    include certs::foreman
  }

  if $certs::generate::candlepin {
    include certs::candlepin
  }

  if $certs::generate::foreman_proxy {
    include certs::foreman_proxy
  }

  if $certs::generate::puppet {
    include certs::puppet
  }
}
