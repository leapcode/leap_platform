class site_haproxy {

    class { 'haproxy':
    enable           => true,
    version          => '1.4.23-0.1~leap60+1',
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

}
