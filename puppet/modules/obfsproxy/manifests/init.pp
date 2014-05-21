class obfsproxy (
  $transport,
  $port,
  $param,
  $dest_ip,
  $dest_port
){

  $user = 'obfsproxy'
  $conf = '/etc/obfsproxy/obfsproxy.conf'

  user { $user:
    ensure => present,
    system => true,
    gid    => $user,
  }

  group { $user:
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
    mode      => '0750',
    require   => File[$conf],
    subscribe => File[$conf],
  }

  file { $conf :
    path    => $conf,
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => template('obfsproxy/etc_conf.erb'),
    require => File['/etc/obfsproxy'],
  }

  file { '/etc/obfsproxy':
    ensure => directory,
    owner  => $user,
    group  => $user,
    mode   => '0700',
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

