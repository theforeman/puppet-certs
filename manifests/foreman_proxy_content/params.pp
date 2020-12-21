# @summary Defaults for certs::foreman_proxy_content::params
# @api private
#
# This class exists because puppet-strings generates a string "[]" rather than
# an empty array in json for defaults. Kafo also can't handle the hash $facts
# even though it's the current recommended default. By adding indirection to a
# class we can work around this.
class certs::foreman_proxy_content::params {
  $parent_fqdn = $facts['networking']['fqdn']
}
