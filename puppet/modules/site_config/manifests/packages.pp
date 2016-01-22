# install default packages and remove unwanted packages
class site_config::packages {


  # base set of packages that we want to have installed everywhere
  package { [ 'etckeeper', 'screen', 'less', 'ntp' ]:
    ensure => installed,
  }

  # base set of packages that we want to remove everywhere
  package { [
    'acpi', 'build-essential',
    'cpp', 'cpp-4.6', 'cpp-4.7', 'cpp-4.8', 'cpp-4.9',
    'eject', 'ftp',
    'g++', 'g++-4.6', 'g++-4.7', 'g++-4.8', 'g++-4.9',
    'gcc', 'gcc-4.6', 'gcc-4.7', 'gcc-4.8', 'gcc-4.9',
    'laptop-detect', 'libc6-dev', 'libssl-dev', 'lpr', 'make', 'portmap',
    'pppconfig', 'pppoe', 'pump', 'qstat',
    'samba-common', 'samba-common-bin', 'smbclient',
    'tcl8.5', 'tk8.5', 'os-prober', 'unzip', 'xauth', 'x11-common',
    'x11-utils', 'xterm' ]:
      ensure => purged;
  }

  notice($::site_config::params::environment)
  if $::site_config::params::environment != 'local' {
    package { [ 'nfs-common', 'nfs-kernel-server', 'rpcbind' ]:
      ensure => purged;
    }
  }
}
