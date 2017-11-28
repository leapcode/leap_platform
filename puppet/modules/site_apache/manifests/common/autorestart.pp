#
# Adds autorestart extension to apache on crash
#
class site_apache::common::autorestart {

  file {
    '/etc/systemd/system/apache2.service.d':
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755';

    # Add .placeholder file so directory doesn't get removed by
    # deb-systemd-helper in a package removal postrm, see
    # issue #8841 for more details.
    '/etc/systemd/system/apache2.service.d/.placeholder':
      ensure => file,
      owner  => 'root',
      group  => 'root',
      mode   => '0755';
  }

  ::systemd::unit_file { 'apache2.service.d/autorestart.conf':
    source  => 'puppet:///modules/site_apache/autorestart.conf',
    require => [
      File['/etc/systemd/system/apache2.service.d'],
      Service['apache'],
    ]
  }
}
