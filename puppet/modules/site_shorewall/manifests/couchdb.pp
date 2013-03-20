class site_shorewall::couchdb {

  include site_shorewall::defaults

  $couchdb_port = '6984'
  # Erlang Port Mapper daemon, used for communication between
  # bigcouch cluster nodes
  $portmapper_port = '5369'

  # define macro for incoming services
  file { '/etc/shorewall/macro.leap_couchdb':
    content => "PARAM   -       -       tcp    ${couchdb_port},${portmapper_port}",
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
