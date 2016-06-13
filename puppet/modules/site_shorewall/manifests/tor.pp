# configure shorewall for tor
class site_shorewall::tor {

  include site_shorewall::defaults
  include site_shorewall::ip_forward

  $tor_port = '9001'

  # define macro for incoming services
  file { '/etc/shorewall/macro.leap_tor':
    content => "PARAM   -       -       tcp    ${tor_port} ",
    notify  => Exec['shorewall_check'],
    require => Package['shorewall']
  }


  shorewall::rule {
      'net2fw-tor':
        source      => 'net',
        destination => '$FW',
        action      => 'leap_tor(ACCEPT)',
        order       => 200;
  }

  include site_shorewall::service::http
}
