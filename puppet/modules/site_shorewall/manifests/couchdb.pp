class site_shorewall::couchdb {

  include site_shorewall::defaults

  $stunnel = hiera('stunnel')
  $couch_server = $stunnel['couch_server']
  $couch_stunnel_port = $couch_server['accept']

  # define macro for incoming services
  file { '/etc/shorewall/macro.leap_couchdb':
    content => "PARAM   -       -       tcp    ${couch_stunnel_port}",
    notify  => Service['shorewall'],
    require => Package['shorewall']
  }

  shorewall::rule {
      'net2fw-couchdb':
        source      => 'net',
        destination => '$FW',
        action      => 'leap_couchdb(ACCEPT)',
        order       => 200;
  }

}
