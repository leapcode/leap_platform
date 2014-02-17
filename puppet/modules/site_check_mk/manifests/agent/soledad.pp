class site_check_mk::agent::soledad {

  # local nagios plugin checks via mrpe
  file_line {
    'Soledad_Procs':
      line => 'Soledad_Procs  /usr/lib/nagios/plugins/check_procs -w 1:1 -c 1:1 -a soledad',
      path => '/etc/check_mk/mrpe.cfg';
  }

}
