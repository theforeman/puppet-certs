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
