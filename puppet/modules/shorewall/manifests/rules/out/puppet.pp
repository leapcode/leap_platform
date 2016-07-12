class shorewall::rules::out::puppet(
  $puppetserver = "puppet.${::domain}",
  $puppetserver_port = 8140,
  $puppetserver_signport = 8141
) {
  class{'shorewall::rules::puppet':
    puppetserver          => $puppetserver,
    puppetserver_port     => $puppetserver_port,
    puppetserver_signport => $puppetserver_signport,
  }
  # we want to connect to the puppet server
  shorewall::rule { 'me-net-puppet_tcp':
    source          =>      '$FW',
    destination     =>      'net:$PUPPETSERVER',
    proto           =>      'tcp',
    destinationport =>      '$PUPPETSERVER_PORT,$PUPPETSERVER_SIGN_PORT',
    order           =>      340,
    action          =>      'ACCEPT';
  }
}
