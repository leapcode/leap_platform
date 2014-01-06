class site_config::packages::base {

  include site_config::params

  # base set of packages that we want to have installed everywhere
  package { [ 'etckeeper', 'screen', 'less', 'ntp' ]:
    ensure => installed,
  }

  # base set of packages that we want to remove everywhere
  package { [ 'acpi', 'acpid', 'acpi-support-base',  'eject', 'ftp', 'fontconfig-config',
              'laptop-detect', 'lpr', 'nfs-common', 'nfs-kernel-server',
              'portmap', 'pppconfig', 'pppoe', 'pump', 'qstat', 'rpcbind',
              'samba-common', 'samba-common-bin', 'smbclient', 'tcl8.5',
              'tk8.5', 'os-prober', 'unzip', 'xauth', 'x11-common',
              'x11-utils', 'xterm' ]:
    ensure => absent;
  }

  if $::site_config::params::environment == 'local' or $::services =~ /\bwebapp\b/ {
    $dev_packages_ensure = present
  } else {
    $dev_packages_ensure = absent
  }

  # g++ and ruby1.9.1-dev are needed for nickserver/eventmachine (#4079)
  # dev_packages are needed for building gems on the webapp node

  package { [ 'build-essential', 'g++', 'g++-4.7', 'gcc',
              'gcc-4.6', 'gcc-4.7', 'cpp', 'cpp-4.6', 'cpp-4.7', 'libc6-dev' ]:
    ensure => $dev_packages_ensure
  }
}
