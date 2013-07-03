class site_config::base_packages {

  # base set of packages that we want to have installed everywhere
  package { [ 'etckeeper', 'screen', 'less' ]:
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

  if $::virtual == 'virtualbox' {
    $virtualbox_ensure = present
  } else {
    $virtualbox_ensure = absent
  }

  package { [ 'build-essential', 'fontconfig-config', 'g++', 'g++-4.7', 'gcc',
              'gcc-4.6', 'gcc-4.7', 'cpp', 'cpp-4.6', 'cpp-4.7', 'libc6-dev' ]:
                ensure => $virtualbox_ensure
  }
}
