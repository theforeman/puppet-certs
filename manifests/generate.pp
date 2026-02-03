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
# $iop::   Generates certificates needed by IOP
#
class certs::generate (
  Boolean $apache = false,
  Boolean $foreman = false,
  Boolean $candlepin = false,
  Boolean $foreman_proxy = false,
  Boolean $puppet = false,
  Boolean $iop = false,
) {
  class { 'certs::apache':
    generate => $apache,
    deploy   => false,
  }

  class { 'certs::foreman':
    generate => $foreman,
    deploy   => false,
  }

  class { 'certs::candlepin':
    generate => $candlepin,
    deploy   => false,
    hostname => 'localhost',
  }

  class { 'certs::foreman_proxy':
    generate => $foreman_proxy,
    deploy   => false,
  }

  class { 'certs::puppet':
    generate => $puppet,
    deploy   => false,
  }

  class { 'certs::iop':
    generate => $iop,
    deploy   => false,
  }
}
