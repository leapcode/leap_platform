class site_shorewall::obfsproxy {

  include site_shorewall::defaults

  $obfsproxy    = hiera('obfsproxy')
  $scramblesuit = $obfsproxy['scramblesuit']
  $scram_port   = $scramblesuit['port']

  # define macro for incoming services
  file { '/etc/shorewall/macro.leap_obfsproxy':
    content => "PARAM   -       -       tcp    ${scram_port} ",
    notify  => Service['shorewall'],
    require => Package['shorewall']
  }

  shorewall::rule {
      'net2fw-obfs':
        source      => 'net',
        destination => '$FW',
        action      => 'leap_obfsproxy(ACCEPT)',
        order       => 200;
  }

}
