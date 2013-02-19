class site_shorewall::service::http {

  include site_shorewall::defaults

  shorewall::rule {
      'net2fw-http':
        source      => 'net',
        destination => '$FW',
        action      => 'HTTP(ACCEPT)',
        order       => 200;
  }

}
