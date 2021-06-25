# @summary Install required tools
# @api private
class certs::install {

  package { 'katello-certs-tools':
    ensure  => installed,
  }

}
