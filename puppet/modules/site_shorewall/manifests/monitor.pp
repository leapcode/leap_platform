class site_shorewall::monitor {

  include site_shorewall::defaults

  shorewall::rule {
      'net2fw-https':
        source      => 'net',
        destination => '$FW',
        action      => 'HTTPS(ACCEPT)',
        order       => 200;
      'net2fw-http':
        source      => 'net',
        destination => '$FW',
        action      => 'HTTP(ACCEPT)',
        order       => 200;
  }

}
