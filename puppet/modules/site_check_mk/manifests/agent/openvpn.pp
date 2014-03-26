class site_check_mk::agent::openvpn {

  # check syslog
  concat::fragment { 'syslog_openpvn':
    source  => 'puppet:///modules/site_check_mk/agent/logwatch/syslog/openvpn.cfg',
    target  => '/etc/check_mk/logwatch.d/syslog.cfg',
    order   => '02';
  }

}
