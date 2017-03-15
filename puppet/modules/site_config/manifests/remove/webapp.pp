# remove leftovers on webapp nodes
class site_config::remove::webapp {
  tidy {
    '/etc/apache/sites-enabled/leap_webapp.conf':
      notify => Service['apache'];
  }

  # Ensure haproxy is removed
  package { 'haproxy':
    ensure => purged,
  }
  augeas { 'haproxy':
    incl    => '/etc/check_mk/mrpe.cfg',
    lens    => 'Spacevars.lns',
    changes => [ 'rm /files/etc/check_mk/mrpe.cfg/Haproxy' ],
    require => File['/etc/check_mk/mrpe.cfg'];
  }

}
