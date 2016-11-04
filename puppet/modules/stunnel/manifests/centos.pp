class stunnel::centos inherits stunnel::linux {

  file { '/etc/init.d/stunnel':
    source  => "puppet:///modules/stunnel/${::operatingsystem}/stunnel.init",
    require => Package['stunnel'],
    before  => Service['stunnel'],
    owner   => root,
    group   => 0,
    mode    => '0755';
  }

  user::managed { 'stunnel':
    homedir => '/var/run/stunnel',
    shell   => '/sbin/nologin',
    uid     => 105,
    gid     => 105;
  }

  Service['stunnel']{
    hasstatus => true,
    require   => [ User['stunnel'], File['/etc/init.d/stunnel'] ]
  }

  file { '/etc/stunnel/stunnel.conf':
    source  => [ "puppet:///modules/site-stunnel/${::fqdn}/stunnel.conf",
                 "puppet:///modules/site-stunnel/${stunnel::cluster}/stunnel.conf",
                 'puppet:///modules/site-stunnel/stunnel.conf',
                 "puppet:///modules/stunnel/${::operatingsystem}/stunnel.conf" ],
    require => Package['stunnel'],
    notify  => Service['stunnel'],
    owner   => root,
    group   => 0,
    mode    => '0600';
  }
}
