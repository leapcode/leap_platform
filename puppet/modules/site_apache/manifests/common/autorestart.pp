#
# Adds autorestart extension to apache on crash
#
class site_apache::common::autorestart {

  ::systemd::unit_file { '/etc/systemd/system/apache2.service.d/autorestart.conf':
    source  => 'puppet:///modules/site_apache/autorestart.conf',
    require => Service['apache'],
  }
}
