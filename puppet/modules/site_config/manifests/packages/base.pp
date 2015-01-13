class site_config::packages::base {


  # base set of packages that we want to have installed everywhere
  package { [ 'etckeeper', 'screen', 'less', 'ntp' ]:
    ensure => installed,
  }

  # base set of packages that we want to remove everywhere
  package { [ 'acpi', 'acpid', 'acpi-support-base',  'eject', 'ftp',
              'laptop-detect', 'lpr', 'nfs-common', 'nfs-kernel-server',
              'portmap', 'pppconfig', 'pppoe', 'pump', 'qstat', 'rpcbind',
              'samba-common', 'samba-common-bin', 'smbclient', 'tcl8.5',
              'tk8.5', 'os-prober', 'unzip', 'xauth', 'x11-common',
              'x11-utils', 'xterm' ]:
    ensure => absent;
  }
}
