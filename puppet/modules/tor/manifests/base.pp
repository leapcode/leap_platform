# basic management of resources for tor
class tor::base {
  package { [ 'tor', 'tor-geoipdb' ]:
    ensure => $tor::ensure_version,
  }

  service { 'tor':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Package['tor'],
  }
}
