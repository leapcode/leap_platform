# Deploy check_mk config
class check_mk::config (
  $site,
  $host_groups               = undef,
  $etc_dir                   = "/omd/sites/${site}/etc",
  $nagios_subdir             = 'nagios',
  $bin_dir                   = "/omd/sites/${site}/bin",
  $use_storedconfigs         = true,
  $inventory_only_on_changes = true
) {
  file {
    # for local check_mk checks
    "${etc_dir}/${nagios_subdir}/local":
      ensure => directory;

    # package provided and check_mk generated files, defined so the nagios
    #  module doesn't purge them
    "${etc_dir}/${nagios_subdir}/conf.d":
      ensure => directory;
    "${etc_dir}/${nagios_subdir}/conf.d/check_mk":
      ensure => directory;
  }
  file_line { 'nagios-add-check_mk-cfg_dir':
    ensure  => present,
    line    => "cfg_dir=${etc_dir}/${nagios_subdir}/local",
    path    => "${etc_dir}/${nagios_subdir}/nagios.cfg",
    require => File["${etc_dir}/${nagios_subdir}/local"],
    #notify  => Class['check_mk::service'],
  }
  file_line { 'add-guest-users':
    ensure => present,
    line   => 'guest_users = [ "guest" ]',
    path   => "${etc_dir}/check_mk/multisite.mk",
    #notify => Class['check_mk::service'],
  }
  concat { "${etc_dir}/check_mk/main.mk":
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    notify => Exec['check_mk-refresh'],
  }
  # all_hosts
  concat::fragment { 'all_hosts-header':
    target  => "${etc_dir}/check_mk/main.mk",
    content => "all_hosts = [\n",
    order   => 10,
  }
  concat::fragment { 'all_hosts-footer':
    target  => "${etc_dir}/check_mk/main.mk",
    content => "]\n",
    order   => 19,
  }
  if ( $use_storedconfigs ) {
    class { 'check_mk::server::collect_hosts': }
    class { 'check_mk::server::collect_ps': }
  }


  # local list of hosts is in /omd/sites/${site}/etc/check_mk/all_hosts_static and is appended
  concat::fragment { 'all-hosts-static':
    ensure => "${etc_dir}/check_mk/all_hosts_static",
    target => "${etc_dir}/check_mk/main.mk",
    order  => 18,
  }
  # host_groups
  if $host_groups {
    file { "${etc_dir}/nagios/local/hostgroups":
      ensure => directory,
    }
    concat::fragment { 'host_groups-header':
      target  => "${etc_dir}/check_mk/main.mk",
      content => "host_groups = [\n",
      order   => 20,
    }
    concat::fragment { 'host_groups-footer':
      target  => "${etc_dir}/check_mk/main.mk",
      content => "]\n",
      order   => 29,
    }
    $groups = keys($host_groups)
    check_mk::hostgroup { $groups:
      dir        => "${etc_dir}/nagios/local/hostgroups",
      hostgroups => $host_groups,
      target     => "${etc_dir}/check_mk/main.mk",
      notify     => Exec['check_mk-refresh']
    }
  }
  # local config is in /omd/sites/${site}/etc/check_mk/main.mk.local and is appended
  concat::fragment { 'check_mk-local-config':
    ensure => "${etc_dir}/check_mk/main.mk.local",
    target => "${etc_dir}/check_mk/main.mk",
    order  => 99,
  }
  # re-read config if it changes
  exec { 'check_mk-refresh':
    command     => "/bin/su -l -c '${bin_dir}/check_mk -II' ${site}",
    refreshonly => $inventory_only_on_changes,
    notify      => Exec['check_mk-reload'],
  }
  exec { 'check_mk-reload':
    command     => "/bin/su -l -c '${bin_dir}/check_mk -O' ${site}",
    refreshonly => $inventory_only_on_changes,
  }
  # re-read inventory at least daily
  exec { 'check_mk-refresh-inventory-daily':
    command  => "/bin/su -l -c '${bin_dir}/check_mk -O' ${site}",
    schedule => 'daily',
  }
}
