class nagios::defaults::hostgroups {
  nagios_hostgroup {
    'all':
      alias   => 'All Servers',
    	members => '*';
    'debian-servers':
      alias   => 'Debian GNU/Linux Servers';
    'centos-servers':
      alias   => 'CentOS GNU/Linux Servers';
  }
}
