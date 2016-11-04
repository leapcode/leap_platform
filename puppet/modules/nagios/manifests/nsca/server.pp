# an nsca server
class nagios::nsca::server {
  package{'nsca':
    ensure => installed
  }

  service { 'nsca':
    ensure     => running,
    hasstatus  => false,
    hasrestart => true,
    require    => Package['nsca'],
  }

  file { '/etc/nsca.cfg':
    source => [ "puppet:///modules/site_nagios/nsca/${::fqdn}/nsca.cfg",
                'puppet:///modules/site_nagios/nsca/nsca.cfg',
                'puppet:///modules/nagios/nsca/nsca.cfg' ],
    owner  => 'nagios',
    group  => 'nogroup',
    mode   => '0400',
    notify => Service['nsca'],
  }

}
