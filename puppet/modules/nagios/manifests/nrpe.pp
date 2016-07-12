# setup nrpe stuff
class nagios::nrpe (
  $cfg_dir = '',
  $pid_file = '',
  $plugin_dir = '',
  $server_address = '',
  $allowed_hosts = '',
  $dont_blame = '0',
) {

  if !($dont_blame in ['0', '1']) {
    fail('Unrecognized value for $dont_blame, must be one of "0", or "1".')
  }

  case $::operatingsystem {
    'FreeBSD': {
      if $cfg_dir == '' { $real_cfg_dir = '/usr/local/etc' }
      if $pid_file == '' { $real_pid_file = '/var/spool/nagios/nrpe2.pid' }
      if $plugin_dir == '' { $real_plugin_dir = '/usr/local/libexec/nagios' }

      include ::nagios::nrpe::freebsd
    }
    'Debian': {
      if $cfg_dir == '' { $real_cfg_dir = '/etc/nagios' }
      if $pid_file == '' { $real_pid_file = '/var/run/nagios/nrpe.pid' }
      if $plugin_dir == '' { $real_plugin_dir = '/usr/lib/nagios/plugins' }
      include ::nagios::nrpe::linux
    }
    default: {
      if $cfg_dir == '' { $real_cfg_dir = '/etc/nagios' }
      if $pid_file == '' { $real_pid_file = '/var/run/nrpe.pid' }
      if $plugin_dir == '' { $real_plugin_dir = '/usr/lib/nagios/plugins' }

      case $::kernel {
        'Linux': { include ::nagios::nrpe::linux }
        default: { include ::nagios::nrpe::base }
      }
    }
  }

}
