class nagios::munin {
  include munin::plugins::base

  munin::plugin::deploy {
    'nagios_hosts':
      source => 'nagios/munin/nagios_hosts',
      config => 'user nagios';
    'nagios_svc':
      source => 'nagios/munin/nagios_svc',
      config => 'user nagios';
    'nagios_perf_hosts':
      source => 'nagios/munin/nagios_perf',
      config => 'user nagios';
    'nagios_perf_svc':
      source => 'nagios/munin/nagios_perf',
      config => 'user nagios';
  }

}
