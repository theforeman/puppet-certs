# Certs Installation
class certs::install {
  include katello::install

  $repo = $certs::custom_repo ? {
    false   => [Katello::Install::Repos['katello']],
    default => []
  }

  package{['katello-certs-tools']:
    ensure  => installed,
    require => $repo
  }

}
