class site_haproxy {
    $haproxy     = hiera('haproxy')
    $local_ports = $haproxy['local_ports']

    class { 'haproxy':
    enable           => true,
    manage_service   => true,
    global_options   => {
      'log'     => '127.0.0.1 local0',
      'maxconn' => '4096',
      'stats'   => 'socket /var/run/haproxy.sock user haproxy group haproxy',
      'chroot'  => '/usr/share/haproxy',
      'user'    => 'haproxy',
      'group'   => 'haproxy',
      'daemon'  => ''
    },
    defaults_options => {
      'log'             => 'global',
      'retries'         => '3',
      'option'          => 'redispatch',
      'timeout connect' => '4000',
      'timeout client'  => '20000',
      'timeout server'  => '20000'
    }
  }

  # monitor haproxy
  concat::fragment { 'stats':
    target => '/etc/haproxy/haproxy.cfg',
    order  => '90',
    source => 'puppet:///modules/site_haproxy/haproxy-stats.cfg';
  }

  # Template uses $global_options, $defaults_options and $haproxy
  concat::fragment { 'leap_haproxy_webapp_couchdb':
    target  => '/etc/haproxy/haproxy.cfg',
    order   => '20',
    content => template('site_webapp/haproxy_couchdb.cfg.erb'),
  }
  
  include site_check_mk::agent::haproxy
}
