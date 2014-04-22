class site_shorewall::mx {

  include site_shorewall::defaults

  $smtpd_ports = '25,465,587'

  # define macro for incoming services
  file { '/etc/shorewall/macro.leap_mx':
    content => "PARAM   -       -       tcp    ${smtpd_ports} ",
    notify  => Service['shorewall'],
    require => Package['shorewall']
  }


  shorewall::rule {
      'net2fw-mx':
        source      => 'net',
        destination => '$FW',
        action      => 'leap_mx(ACCEPT)',
        order       => 200;
  }

  include site_shorewall::service::smtp
}
