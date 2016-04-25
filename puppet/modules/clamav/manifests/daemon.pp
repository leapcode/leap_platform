# deploy clamav daemon
class clamav::daemon {

  $domain_hash           = hiera('domain')
  $domain                = $domain_hash['full_suffix']

  package { [ 'clamav-daemon', 'arj' ]:
    ensure => installed;
  }

  service {
    'clamav-daemon':
      ensure     => running,
      name       => clamav-daemon,
      pattern    => '/usr/sbin/clamd',
      enable     => true,
      hasrestart => true,
      subscribe  => File['/etc/default/clamav-daemon'],
      require    => Package['clamav-daemon'];
  }

  file {
    '/var/run/clamav':
      ensure  => directory,
      mode    => '0750',
      owner   => clamav,
      group   => postfix,
      require => [Package['postfix'], Package['clamav-daemon']];

    '/var/lib/clamav':
      mode    => '0755',
      owner   => clamav,
      group   => clamav,
      require => Package['clamav-daemon'];

    '/etc/default/clamav-daemon':
      source => 'puppet:///modules/clamav/clamav-daemon_default',
      mode   => '0644',
      owner  => root,
      group  => root;

    # this file contains additional domains that we want the clamav
    # phishing process to look for (our domain)
    '/var/lib/clamav/local.pdb':
      content => template('clamav/local.pdb.erb'),
      mode    => '0644',
      owner   => clamav,
      group   => clamav,
      require => Package['clamav-daemon'];
  }

  file_line {
    'clamav_daemon_tmp':
      path    => '/etc/clamav/clamd.conf',
      line    => 'TemporaryDirectory /var/tmp',
      require => Package['clamav-daemon'],
      notify  => Service['clamav-daemon'];

    'enable_phishscanurls':
      path    => '/etc/clamav/clamd.conf',
      match   => 'PhishingScanURLs no',
      line    => 'PhishingScanURLs yes',
      require => Package['clamav-daemon'],
      notify  => Service['clamav-daemon'];

    'clamav_LogSyslog_true':
      path    => '/etc/clamav/clamd.conf',
      match   => '^LogSyslog false',
      line    => 'LogSyslog true',
      require => Package['clamav-daemon'],
      notify  => Service['clamav-daemon'];

    'clamav_MaxThreads':
      path    => '/etc/clamav/clamd.conf',
      match   => 'MaxThreads 20',
      line    => 'MaxThreads 100',
      require => Package['clamav-daemon'],
      notify  => Service['clamav-daemon'];
  }

  # remove LogFile line
  file_line {
    'clamav_LogFile':
      path    => '/etc/clamav/clamd.conf',
      match   => '^LogFile .*',
      line    => '',
      require => Package['clamav-daemon'],
      notify  => Service['clamav-daemon'];
  }

}
