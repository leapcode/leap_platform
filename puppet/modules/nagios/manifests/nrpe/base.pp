# basic nrpe stuff
class nagios::nrpe::base {

  # Import all variables from entry point
  $cfg_dir = $::nagios::nrpe::real_cfg_dir
  $pid_file = $::nagios::nrpe::real_pid_file
  $plugin_dir = $::nagios::nrpe::real_plugin_dir
  $server_address = $::nagios::nrpe::server_address
  $allowed_hosts = $::nagios::nrpe::allowed_hosts
  $dont_blame = $::nagios::nrpe::dont_blame

  package{['nagios-nrpe-server', 'nagios-plugins-basic', 'libwww-perl']:
    ensure => installed;
  }

  # Special-case lenny. the package doesn't exist
  if $::lsbdistcodename != 'lenny' {
    package{'libnagios-plugin-perl': ensure => installed; }
  }

  file{
    [ $cfg_dir, "${cfg_dir}/nrpe.d" ]:
      ensure => directory;
  }

  file { "${cfg_dir}/nrpe.cfg":
    content => template('nagios/nrpe/nrpe.cfg'),
    owner   => root,
    group   => 0,
    mode    => '0644';
  }

  # default commands
  nagios::nrpe::command{'basic_nrpe':
    source => [ "puppet:///modules/site_nagios/configs/nrpe/nrpe_commands.${::fqdn}.cfg",
                'puppet:///modules/site_nagios/configs/nrpe/nrpe_commands.cfg',
                'puppet:///modules/nagios/nrpe/nrpe_commands.cfg' ],
  }
  # the check for load should be customized for each server based on number
  # of CPUs and the type of activity.
  $warning_1_threshold = 7 * $::processorcount
  $warning_5_threshold = 6 * $::processorcount
  $warning_15_threshold = 5 * $::processorcount
  $critical_1_threshold = 10 * $::processorcount
  $critical_5_threshold = 9 * $::processorcount
  $critical_15_threshold = 8 * $::processorcount
  nagios::nrpe::command {'check_load':
    command_line => "${plugin_dir}/check_load -w ${warning_1_threshold},${warning_5_threshold},${warning_15_threshold} -c ${critical_1_threshold},${critical_5_threshold},${critical_15_threshold}",
  }

  service{'nagios-nrpe-server':
    ensure    => running,
    enable    => true,
    pattern   => 'nrpe',
    subscribe => File["${cfg_dir}/nrpe.cfg"],
    require   => Package['nagios-nrpe-server'],
  }
}
