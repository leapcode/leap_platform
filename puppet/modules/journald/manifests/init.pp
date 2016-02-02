class journald {

    service { 'systemd-journald':
      ensure => running,
      enable => true,
    }
}
