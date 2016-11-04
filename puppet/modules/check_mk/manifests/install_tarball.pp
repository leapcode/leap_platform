class check_mk::install_tarball (
  $filestore,
  $version,
  $workspace,
) {
  package { 'nagios':
    ensure => present,
    notify => Exec['set-nagiosadmin-password', 'set-guest-password', 'add-apache-to-nagios-group'],
  }
  file { '/etc/nagios/passwd':
    ensure => present,
    owner  => 'root',
    group  => 'apache',
    mode   => '0640',
  }
  exec { 'set-nagiosadmin-password':
    command     => '/usr/bin/htpasswd -b /etc/nagios/passwd nagiosadmin letmein',
    refreshonly => true,
    require     => File['/etc/nagios/passwd'],
  }
  exec { 'set-guest-password':
    command     => '/usr/bin/htpasswd -b /etc/nagios/passwd guest guest',
    refreshonly => true,
    require     => File['/etc/nagios/passwd'],
  }
  exec { 'add-apache-to-nagios-group':
    command     => '/usr/sbin/usermod -a -G nagios apache',
    refreshonly => true,
  }
  package { 'nagios-plugins-all':
    ensure  => present,
    require => Package['nagios'],
  }
  # FIXME: this should get and check $use_ssh before requiring xinetd
  package { [ 'xinetd', 'mod_python', 'make', 'gcc-c++', 'tar', 'gzip' ]:
    ensure  => present,
  }
  file { "${workspace}/check_mk-${version}.tar.gz":
    ensure  => present,
    source  => "${filestore}/check_mk-${version}.tar.gz",
  }
  exec { 'unpack-check_mk-tarball':
    command     => "/bin/tar -zxf ${workspace}/check_mk-${version}.tar.gz",
    cwd         => $workspace,
    creates     => "${workspace}/check_mk-${version}",
    require     => File["${workspace}/check_mk-${version}.tar.gz"],
  }
  exec { 'change-setup-config-location':
    command => "/usr/bin/perl -pi -e 's#^SETUPCONF=.*?$#SETUPCONF=${workspace}/check_mk_setup.conf#' ${workspace}/check_mk-${version}/setup.sh",
    unless  => "/bin/egrep '^SETUPCONF=${workspace}/check_mk_setup.conf$' ${workspace}/check_mk-${version}/setup.sh",
    require => Exec['unpack-check_mk-tarball'],
  }
  # Avoid header like 'Written by setup of check_mk 1.2.0p3 at Thu Feb  7 12:26:17 GMT 2013'
  # that changes every time the setup script is run
  exec { 'remove-setup-header':
    command => "/usr/bin/perl -pi -e 's#^DIRINFO=.*?$#DIRINFO=#' ${workspace}/check_mk-${version}/setup.sh",
    unless  => "/bin/egrep '^DIRINFO=$' ${workspace}/check_mk-${version}/setup.sh",
    require => Exec['unpack-check_mk-tarball'],
  }
  file { "${workspace}/check_mk_setup.conf":
    ensure  => present,
    content => template('check_mk/setup.conf.erb'),
    notify  => Exec['check_mk-setup'],
  }
  file { '/etc/nagios/check_mk':
    ensure  => directory,
    owner   => 'nagios',
    group   => 'nagios',
    recurse => true,
    require => Package['nagios'],
  }
  file { '/etc/nagios/check_mk/hostgroups':
    ensure  => directory,
    owner   => 'nagios',
    group   => 'nagios',
    require => File['/etc/nagios/check_mk'],
  }
  exec { 'check_mk-setup':
    command     => "${workspace}/check_mk-${version}/setup.sh --yes",
    cwd         => "${workspace}/check_mk-${version}",
    refreshonly => true,
    require     => [
      Exec['change-setup-config-location'],
      Exec['remove-setup-header'],
      Exec['unpack-check_mk-tarball'],
      File["${workspace}/check_mk_setup.conf"],
      File['/etc/nagios/check_mk'],
      Package['nagios'],
    ],
    notify      => Class['check_mk::service'],
  }
}
