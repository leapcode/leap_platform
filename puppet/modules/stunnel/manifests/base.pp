class stunnel::base {

  file { '/etc/stunnel':
    ensure => directory;
  }

  service { 'stunnel':
    ensure    => running,
    name      => 'stunnel',
    enable    => true,
    hasstatus => false;
  }
}
