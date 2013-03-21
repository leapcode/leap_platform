class site_shorewall::couchdb {

  include site_shorewall::defaults

  $couchdb_port = '6984'
  # Erlang Port Mapper daemon, used for communication between
  # bigcouch cluster nodes
  $portmapper_port = '5369'

  # see http://stackoverflow.com/questions/8459949/bigcouch-cluster-connection-issue#comment10467603_8463814
  $erlang_vm_port = '9001'

  # define macro for incoming services
  file { '/etc/shorewall/macro.leap_couchdb':
    content => "PARAM   -       -       tcp    ${couchdb_port},${portmapper_port},${erlang_vm_port}",
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
