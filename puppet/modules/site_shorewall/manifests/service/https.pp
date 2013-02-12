class site_shorewall::service::https {

  include site_shorewall::defaults

  shorewall::rule {
      'net2fw-https':
        source      => 'net',
        destination => '$FW',
        action      => 'HTTPS(ACCEPT)',
        order       => 200;
  }
}
