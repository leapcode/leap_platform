class site_shorewall::soledad {

  include site_shorewall::defaults

  # define macro for incoming services
  file { '/etc/shorewall/macro.leap_soledad':
    content => 'PARAM   -       -       tcp    2424',
    notify  => Service['shorewall'],
    require => Package['shorewall']
  }

  shorewall::rule {
    'net2fw-soledad':
      source      => 'net',
      destination => '$FW',
      action      => 'leap_soledad(ACCEPT)',
      order       => 200;
  }
}

