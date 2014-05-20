class obfsproxy (
  $transport,
  $port,
  $param,
  $dest_ip,
  $dest_port
){

  user { obfsproxy:
    ensure => present,
    system => true,
    gid    => obfsproxy,
  }

  group { obfsproxy:
    ensure => present,
    system => true,
  }

#  file { '/etc/default/obfsproxy':
#    path    => '/etc/default/obfsproxy',
#    owner   => 'root',
#    group   => 'root',
#    mode    => '0750',
#    content => template('obfsproxy/etc_default_conf.erb'),
#  }

  file { '/etc/init.d/obfsproxy':
    path      => '/etc/init.d/obfsproxy',
    ensure    => present,
    source    => 'puppet:///modules/obfsproxy/obfsproxy_daemon',
    owner     => 'root',
    group     => 'root',
    mode      => '0755',
    require   => File['/etc/obfsproxy.conf'],
    subscribe => File['/etc/obfsproxy.conf'],
    #content  => template('obfsproxy/etc_init_d.erb'),
  }

  file { '/etc/obfsproxy.conf':
    path    => '/etc/obfsproxy.conf',
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    content => template('obfsproxy/etc_conf.erb'),
  }

  package { "obfsproxy":
    ensure => present,
  }

  service { "obfsproxy":
    ensure  => running,
    status  => '/usr/sbin/service obfsproxy status
                | grep "is running"',
    require => [
      Package["obfsproxy"],
      File["/etc/init.d/obfsproxy"] ]
  }


}

