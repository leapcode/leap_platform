class site_shorewall::couchdb {

  include site_shorewall::defaults

  $couchdb_port = '6984'

  # define macro for incoming services
  file { '/etc/shorewall/macro.leap_couchdb':
    content => "PARAM   -       -       tcp    $couchdb_port",
    notify  => Service['shorewall']
  }


  shorewall::rule {
      'net2fw-couchdb':
        source      => 'net',
        destination => '$FW',
        action      => 'leap_couchdb(ACCEPT)',
        order       => 200;
  }

}
