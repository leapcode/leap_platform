class site_check_mk::agent::haproxy {

  include site_check_mk::agent::package::nagios_plugins_contrib

  # local nagios plugin checks via mrpe
  file_line {
    'haproxy':
      line => 'Haproxy  /usr/lib/nagios/plugins/check_haproxy -u "http://localhost:8000/haproxy;csv"',
      path => '/etc/check_mk/mrpe.cfg';
  }

}
