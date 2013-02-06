class site_shorewall::webapp {

  include site_shorewall::defaults

  shorewall::rule {
      'net2fw-https':
        source      => 'net',
        destination => '$FW',
        action      => 'HTTPS(ACCEPT)',
        order       => 200;
  }

}
