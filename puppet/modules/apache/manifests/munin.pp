# manage apache monitoring things
class apache::munin {
  if $::osfamily == 'Debian' {
    include perl::extensions::libwww
  }

  munin::plugin{ [ 'apache_accesses', 'apache_processes', 'apache_volume' ]: }
  munin::plugin::deploy { 'apache_activity':
    source  => 'apache/munin/apache_activity',
    seltype => 'munin_services_plugin_exec_t',
  }
}
