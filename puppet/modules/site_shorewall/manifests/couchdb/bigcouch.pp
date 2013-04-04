class site_shorewall::couchdb::bigcouch {

  include site_shorewall::defaults

  $stunnel = hiera('stunnel')

  # Erlang Port Mapper Daemon (epmd) stunnel server/clients
  $epmd_clients         = $stunnel['epmd_clients']
  $epmd_server          = $stunnel['epmd_server']
  $epmd_server_port     = $epmd_server['accept']
  $epmd_server_connect  = $epmd_server['connect']

  # Erlang Distributed Node Protocol (ednp) stunnel server/clients
  $ednp_clients         = $stunnel['ednp_clients']
  $ednp_server          = $stunnel['ednp_server']
  $ednp_server_port     = $ednp_server['accept']
  $ednp_server_connect  = $ednp_server['connect']

  # define macro for incoming services
  file { '/etc/shorewall/macro.leap_bigcouch':
    content => "PARAM   -       -       tcp    ${epmd_server_port},${ednp_server_port}",
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

  # setup DNAT rules for each epmd
  $epmd_shorewall_dnat_defaults = {
    'source'          => '$FW',
    'proto'           => 'tcp',
    'destinationport' => regsubst($epmd_server_connect, '^([0-9.]+:)([0-9]+)$', '\2')
  }
  create_resources(site_shorewall::couchdb::dnat, $epmd_clients, $epmd_shorewall_dnat_defaults)

  # setup DNAT rules for each ednp
  $ednp_shorewall_dnat_defaults = {
    'source'          => '$FW',
    'proto'           => 'tcp',
    'destinationport' => regsubst($ednp_server_connect, '^([0-9.]+:)([0-9]+)$', '\2')
  }
  create_resources(site_shorewall::couchdb::dnat, $ednp_clients, $ednp_shorewall_dnat_defaults)

}

