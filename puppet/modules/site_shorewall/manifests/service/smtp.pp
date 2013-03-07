class site_shorewall::service::smtp {

  include site_shorewall::defaults

  shorewall::rule {
      'fw2net-http':
        source      => '$FW',
        destination => 'net',
        action      => 'SMTP(ACCEPT)',
        order       => 200;
  }

}
