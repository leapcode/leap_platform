class site_mx::haproxy {

  include site_haproxy

  $haproxy     = hiera('haproxy')
  $local_ports = $haproxy['local_ports']

  # Template uses $global_options, $defaults_options
  concat::fragment { 'leap_haproxy_webapp_couchdb':
    target  => '/etc/haproxy/haproxy.cfg',
    order   => '20',
    content => template('site_webapp/haproxy_couchdb.cfg.erb'),
  }
}
