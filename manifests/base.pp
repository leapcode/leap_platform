# basic stuff for nagios
class nagios::base {
  # include the variables
  include ::nagios::defaults::vars

  package { 'nagios':
    ensure  => present,
  }

  service { 'nagios':
    ensure  => running,
    enable  => $nagios::service_at_boot,
    require => Package['nagios'],
  }

  $cfg_dir = $nagios::defaults::vars::int_cfgdir
  # this file should contain all the nagios_puppet-paths:
  file{
    'nagios_cfgdir':
      ensure  => directory,
      path    => $cfg_dir,
      alias   => nagios_confd,
      recurse => true,
      purge   => true,
      force   => true,
      require => Package['nagios'],
      notify  => Service['nagios'],
      owner   => root,
      group   => root,
      mode    => '0755';
    'nagios_main_cfg':
      path    => "${cfg_dir}/nagios.cfg",
      source  => [ "puppet:///modules/site_nagios/configs/${::fqdn}/nagios.cfg",
                    "puppet:///modules/site_nagios/configs/${::operatingsystem}/nagios.cfg",
                    'puppet:///modules/site_nagios/configs/nagios.cfg',
                    "puppet:///modules/nagios/configs/${::operatingsystem}/nagios.cfg",
                    'puppet:///modules/nagios/configs/nagios.cfg' ],
      notify  => Service['nagios'],
      owner   => root,
      group   => root,
      mode    => '0644';
    'nagios_cgi_cfg':
      path    => "${cfg_dir}/cgi.cfg",
      source  => [ "puppet:///modules/site_nagios/configs/${::fqdn}/cgi.cfg",
                    "puppet:///modules/site_nagios/configs/${::operatingsystem}/cgi.cfg",
                    'puppet:///modules/site_nagios/configs/cgi.cfg',
                    "puppet:///modules/nagios/configs/${::operatingsystem}/cgi.cfg",
                    'puppet:///modules/nagios/configs/cgi.cfg' ],
      notify  => Service['apache'],
      owner   => 'root',
      group   => 0,
      mode    => '0644';
    'nagios_htpasswd':
      path    => "${cfg_dir}/htpasswd.users",
      source  => [ 'puppet:///modules/site_nagios/htpasswd.users',
                    'puppet:///modules/nagios/htpasswd.users' ],
      owner   => root,
      group   => apache,
      mode    => '0640';
    'nagios_resource_cfg':
      path    => "${cfg_dir}/resource.cfg",
      source  => [ "puppet:///modules/site_nagios/configs/${::operatingsystem}/private/resource.cfg.${::architecture}",
                    "puppet:///modules/nagios/configs/${::operatingsystem}/private/resource.cfg.${::architecture}" ],
      notify  => Service['nagios'],
      owner   => root,
      group   => nagios,
      mode    => '0640';
  }

  if $cfg_dir == '/etc/nagios3' {
    file{'/etc/nagios':
      ensure => link,
      target => $cfg_dir,
      before => File['nagios_cfgdir'],
    }
  }

  file{
    [ "${cfg_dir}/nagios_command.cfg",
      "${cfg_dir}/nagios_contact.cfg",
      "${cfg_dir}/nagios_contactgroup.cfg",
      "${cfg_dir}/nagios_host.cfg",
      "${cfg_dir}/nagios_hostdependency.cfg",
      "${cfg_dir}/nagios_hostescalation.cfg",
      "${cfg_dir}/nagios_hostextinfo.cfg",
      "${cfg_dir}/nagios_hostgroup.cfg",
      "${cfg_dir}/nagios_hostgroupescalation.cfg",
      "${cfg_dir}/nagios_service.cfg",
      "${cfg_dir}/nagios_servicedependency.cfg",
      "${cfg_dir}/nagios_serviceescalation.cfg",
      "${cfg_dir}/nagios_serviceextinfo.cfg",
      "${cfg_dir}/nagios_servicegroup.cfg",
      "${cfg_dir}/nagios_timeperiod.cfg" ]:
      ensure  => file,
      replace => false,
      notify  => Service['nagios'],
      require => File['nagios_cfgdir'],
      owner   => root,
      group   => 0,
      mode    => '0644';
  }

  resources {
    [
      'nagios_command',
      'nagios_contactgroup',
      'nagios_contact',
      'nagios_hostdependency',
      'nagios_hostescalation',
      'nagios_hostextinfo',
      'nagios_hostgroup',
      'nagios_host',
      'nagios_servicedependency',
      'nagios_serviceescalation',
      'nagios_servicegroup',
      'nagios_serviceextinfo',
      'nagios_service',
      'nagios_timeperiod',
    ]:
      notify => Service['nagios'],
      purge  => $::nagios::purge_resources
  }

  # make sure nagios resources are defined after nagios is
  # installed and the nagios_cfgdir resource is present
  File['nagios_cfgdir'] -> Nagios_command <||>
  File['nagios_cfgdir'] -> Nagios_contactgroup <||>
  File['nagios_cfgdir'] -> Nagios_contact <||>
  File['nagios_cfgdir'] -> Nagios_hostdependency <||>
  File['nagios_cfgdir'] -> Nagios_hostescalation <||>
  File['nagios_cfgdir'] -> Nagios_hostextinfo <||>
  File['nagios_cfgdir'] -> Nagios_hostgroup <||>
  File['nagios_cfgdir'] -> Nagios_host <||>
  File['nagios_cfgdir'] -> Nagios_servicedependency <||>
  File['nagios_cfgdir'] -> Nagios_serviceescalation <||>
  File['nagios_cfgdir'] -> Nagios_servicegroup <||>
  File['nagios_cfgdir'] -> Nagios_serviceextinfo <||>
  File['nagios_cfgdir'] -> Nagios_service <||>
  File['nagios_cfgdir'] -> Nagios_timeperiod <||>

  if ( $nagios::storeconfigs == true ) {
    include ::nagios::storeconfigs
  }
}
