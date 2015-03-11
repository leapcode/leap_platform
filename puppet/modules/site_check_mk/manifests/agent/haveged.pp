class site_check_mk::agent::haveged {

# check haveged process
  augeas {
    'haveged_proc':
      incl    => '/etc/check_mk/mrpe.cfg',
      lens    => 'Spacevars.lns',
      changes => [
        'rm /files/etc/check_mk/mrpe.cfg/haveged_proc',
        'set haveged_proc \'/usr/lib/nagios/plugins/check_procs -w 1:1 -c 1:1 -a /usr/sbin/haveged\'' ];
  }

}
