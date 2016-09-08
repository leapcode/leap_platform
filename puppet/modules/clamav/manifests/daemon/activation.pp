# ensure clamav starts after the definitions are downloaded
# needed because sometimes clamd cannot get started by freshclam,
# see https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=827909
class clamav::daemon::activation {

  file { '/etc/systemd/system/clamav-daemon.path':
    source => 'puppet:///modules/clamav/clamav-daemon.path',
    mode   => '0644',
    owner  => root,
    group  => root,
    notify => [ Exec['systemctl-daemon-reload'], Systemd::Enable['clamav-daemon.path'] ]
  }

  systemd::enable { 'clamav-daemon.path':
    require => Exec['systemctl-daemon-reload'],
    notify  => Exec['start_clamd_path_monitor']
  }

  exec { 'start_clamd_path_monitor':
      command     => '/bin/systemctl start clamav-daemon.path',
      refreshonly => true,
      before      => Service['freshclam']
  }
}
