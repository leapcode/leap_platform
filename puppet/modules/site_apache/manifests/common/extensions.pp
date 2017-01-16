class site_apache::common::extensions {

  include ::systemd
  file { '/etc/systemd/system/apache2.service.d/auto_restart.conf':
    source  => 'puppet:///modules/site_apache/auto_restart.conf',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Service['apache'],
    notify  => Exec['systemctl-daemon-reload']
  }
}
