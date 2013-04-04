class site_shorewall::couchdb::bigcouch {

  include site_shorewall::defaults

  $stunnel = hiera('stunnel')
  $epmd_clients         = $stunnel['epmd_clients']

  $epmd_server          = $stunnel['epmd_server']
  $epmd_server_port     = $epmd_server['accept']
  $epmd_server_connect  = $epmd_server['connect']

  # define macro for incoming services
  file { '/etc/shorewall/macro.leap_bigcouch':
    content => "PARAM   -       -       tcp    ${epmd_server_port}",
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

  $epmd_shorewall_dnat_defaults = {
    'source'          => '$FW',
    'proto'           => 'tcp',
    'destinationport' => regsubst($epmd_server_connect, '^([0-9.]+:)([0-9]+)$', '\2')
  }

  create_resources(site_shorewall::couchdb::dnat, $epmd_clients, $epmd_shorewall_dnat_defaults)

}

