#
# Adds autorestart extension to apache on crash
#
class site_apache::common::autorestart {

  include ::systemd
  file { '/etc/systemd/system/apache2.service.d/autorestart.conf':
    source  => 'puppet:///modules/site_apache/autorestart.conf',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Service['apache'],
    notify  => Exec['systemctl-daemon-reload']
  }
}
