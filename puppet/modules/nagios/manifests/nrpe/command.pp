# manage an nrpe command
define nagios::nrpe::command (
  $ensure       = present,
  $command_line = '',
  $source       = '',
){
  if ($command_line == '' and $source == '') {
    fail('Either one of $command_line or $source must be given to nagios::nrpe::command.' )
  }

  $cfg_dir = $nagios::nrpe::real_cfg_dir

  file{"${cfg_dir}/nrpe.d/${name}_command.cfg":
    ensure  => $ensure,
    notify  => Service['nagios-nrpe-server'],
    require => File["${cfg_dir}/nrpe.d" ],
    owner   => 'root',
    group   => 0,
    mode    => '0644';
  }

  case $source {
    '': {
      File["${cfg_dir}/nrpe.d/${name}_command.cfg"] {
        content => template('nagios/nrpe/nrpe_command.erb'),
      }
    }
    default: {
      File["${cfg_dir}/nrpe.d/${name}_command.cfg"] {
        source => $source,
      }
    }
  }
}
