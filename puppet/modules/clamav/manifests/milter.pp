class clamav::milter {

  $clamav                = hiera('clamav')
  $whitelisted_addresses = $clamav['whitelisted_addresses']
  $domain_hash           = hiera('domain')
  $domain                = $domain_hash['full_suffix']

  package { 'clamav-milter': ensure => installed }

  service {
    'clamav-milter':
      ensure     => running,
      enable     => true,
      name       => clamav-milter,
      pattern    => '/usr/sbin/clamav-milter',
      hasrestart => true,
      require    => Package['clamav-milter'],
      subscribe  => File['/etc/default/clamav-milter'];
  }

  file {
    '/run/clamav/milter.ctl':
      mode    => '0666',
      owner   => clamav,
      group   => postfix,
      require => Class['clamav::daemon'];

    '/etc/clamav/clamav-milter.conf':
      content   => template('clamav/clamav-milter.conf.erb'),
      mode      => '0644',
      owner     => root,
      group     => root,
      require   => Package['clamav-milter'],
      subscribe => Service['clamav-milter'];

    '/etc/default/clamav-milter':
      source => 'puppet:///modules/clamav/clamav-milter_default',
      mode   => '0644',
      owner  => root,
      group  => root;

    '/etc/clamav/whitelisted_addresses':
      content => template('clamav/whitelisted_addresses.erb'),
      mode    => '0644',
      owner   => root,
      group   => root,
      require => Package['clamav-milter'];
  }

}
