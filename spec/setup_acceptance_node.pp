$major = $facts['os']['release']['major']

# Defaults to staging, for release, use
# $baseurl = "https://yum.theforeman.org/releases/nightly/el${major}/x86_64/"
$baseurl = "http://koji.katello.org/releases/yum/foreman-nightly/RHEL/${major}/x86_64/"

yumrepo { 'foreman':
  baseurl  => $baseurl,
  gpgcheck => 0,
}
