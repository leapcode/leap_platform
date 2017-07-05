#
# Adds autorestart extension to apache on crash
#
class site_apache::common::autorestart {

  file { '/etc/systemd/system/apache2.service.d':
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => '0755',
  }

  ::systemd::unit_file { 'apache2.service.d/autorestart.conf':
    source  => 'puppet:///modules/site_apache/autorestart.conf',
    require => [
      File['/etc/systemd/system/apache2.service.d'],
      Service['apache'],
    ]
  }
}
