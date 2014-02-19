class site_check_mk::agent::tapicero {

  # local nagios plugin checks via mrpe
  file_line {
    'Tapicero_Procs':
      line => 'Tapicero_Procs  /usr/lib/nagios/plugins/check_procs -w 1:1 -c 1:1 -a tapicero',
      path => '/etc/check_mk/mrpe.cfg';
  }

}
