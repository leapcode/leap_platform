class site_shorewall::couchdb::bigcouch {

  include site_shorewall::defaults

  $stunnel = hiera('stunnel')
  $bigcouch_replication_clients         = $stunnel['bigcouch_replication_clients']

  $bigcouch_replication_server          = $stunnel['bigcouch_replication_server']
  $bigcouch_replication_server_port     = $bigcouch_replication_server['accept']

  # define macro for incoming services
  file { '/etc/shorewall/macro.leap_bigcouch':
    content => "PARAM   -       -       tcp    ${bigcouch_replication_server_port}",
    notify  => Service['shorewall'],
    require => Package['shorewall']
  }

  shorewall::rule {
      'net2fw-bigcouch':
        source      => 'net',
        destination => '$FW',
        action      => 'leap_bigcouch(ACCEPT)',
        order       => 300;
  }

  $bigcouch_shorewall_dnat_defaults = {
    'source'          => '$FW',
    'proto'           => 'tcp',
    'destinationport' => '4369',
  }

  create_resources(site_shorewall::couchdb::dnat, $bigcouch_replication_clients, $bigcouch_shorewall_dnat_defaults)

}

