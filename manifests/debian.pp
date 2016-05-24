class stunnel::debian inherits stunnel::linux {

  Package['stunnel'] {
    name => 'stunnel4',
  }

  Service['stunnel'] {
    name => 'stunnel4',
    pattern => '/usr/bin/stunnel4',
  }

  file { '/etc/default/stunnel4':
    content => template('stunnel/Debian/default'),
    require => Package['stunnel4'],
    notify  => Service['stunnel4'],
    owner   => root,
    group   => 0,
    mode    => '0644';
  }
}

