class { 'foreman::repo':
  repo => 'nightly',
}

group { 'pulp':
  ensure => present
}

file { '/etc/pulp':
  ensure => directory,
  owner  => 'root',
  mode   => '0770',
}

package { 'java-17-openjdk-headless':
  ensure => installed,
}
