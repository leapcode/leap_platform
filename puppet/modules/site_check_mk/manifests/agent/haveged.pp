class site_check_mk::agent::haveged {

# check haveged process
  file_line {
    'haveged_proc':
      line => 'haveged_proc  /usr/lib/nagios/plugins/check_procs -w 1:1 -c 1:1 -a /usr/sbin/haveged',
      path => '/etc/check_mk/mrpe.cfg';
  }
}
