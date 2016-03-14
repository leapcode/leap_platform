class obfsproxy (
  $transport,
  $bind_address,
  $port,
  $param,
  $dest_ip,
  $dest_port,
  $log_level = 'info'
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

  file { '/etc/init.d/obfsproxy':
    path      => '/etc/init.d/obfsproxy',
    ensure    => present,
    source    => 'puppet:///modules/obfsproxy/obfsproxy_init',
    owner     => 'root',
    group     => 'root',
    mode      => '0750',
    require   => File[$conf],
  }

  file { $conf :
    path    => $conf,
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => template('obfsproxy/etc_conf.erb'),
  }

  file { '/etc/obfsproxy':
    ensure  => directory,
    owner   => $user,
    group   => $user,
    mode    => '0700',
    require => User[$user],
  }

  file { '/var/log/obfsproxy.log':
    ensure  => present,
    owner   => $user,
    group   => $user,
    mode    => '0640',
    require => User[$user],
  }

  file { '/etc/logrotate.d/obfsproxy':
    ensure  => present,
    source  => 'puppet:///modules/obfsproxy/obfsproxy_logrotate',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File['/var/log/obfsproxy.log'],
  }

  package { 'obfsproxy':
    ensure  => present
  }

  service { 'obfsproxy':
    ensure    => running,
    subscribe => File[$conf],
    require   => [
      Package['obfsproxy'],
      File['/etc/init.d/obfsproxy'],
      User[$user],
      Group[$user]]
  }


}

