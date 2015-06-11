class haveged {

  package { 'haveged':
    ensure => present,
  }

  service { 'haveged':
    ensure     => running,
    hasrestart => true,
    hasstatus  => true,
    enable     => true,
    require    => Package['haveged'];
  }

  include site_check_mk::agent::haveged
}
