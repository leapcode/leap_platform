class site_check_mk::agent::haproxy {

  include site_check_mk::agent::package::nagios_plugins_contrib

  # local nagios plugin checks via mrpe
  augeas { 'haproxy':
    incl    => '/etc/check_mk/mrpe.cfg',
    lens    => 'Spacevars.lns',
    changes => [
      'rm /files/etc/check_mk/mrpe.cfg/Haproxy',
      'set Haproxy \'/usr/lib/nagios/plugins/check_haproxy -u "http://localhost:8000/haproxy;csv"\'' ];
  }

}
