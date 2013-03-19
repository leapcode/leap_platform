class site_haproxy {

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
      'log'        => 'global',
      'retries'    => '3',
      'option'     => 'redispatch',
      'contimeout' => '5000',
      'clitimeout' => '50000',
      'srvtimeout' => '50000'
    }
  }

}
