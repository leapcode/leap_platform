class sshd::autossh($host,
                    $port = undef, # this should be a remote->local hash
                    $remote_user = undef,
                    $user = 'root',
                    $pidfile = '/var/run/autossh.pid',
) {
  if $port {
    $port_ensure = $port
  }
  else {
    # random port between 10000 and 20000
    $port_ensure = fqdn_rand(10000) + 10000
  }
  if $remote_user {
    $remote_user_ensure = $remote_user
  }
  else {
    $remote_user_ensure = "host-$fqdn"
  }
  file {
    '/etc/init.d/autossh':
      mode   => '0555',
      source => 'puppet:///modules/sshd/autossh.init.d';
    '/etc/default/autossh':
      mode    => '0444',
      content => "USER=$user\nPIDFILE=$pidfile\nDAEMON_ARGS='-M0 -f -o ServerAliveInterval=15 -o ServerAliveCountMax=4 -q -N -R $port_ensure:localhost:22 $remote_user_ensure@$host'\n";
  }
  package { 'autossh':
    ensure => present,
  }
  service { 'autossh':
    ensure    => running,
    enable    => true,
    subscribe => [
                  File['/etc/init.d/autossh'],
                  File['/etc/default/autossh'],
                  Package['autossh'],
                  ],
  }
}
