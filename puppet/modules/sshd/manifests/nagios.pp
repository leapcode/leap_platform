define sshd::nagios(
  $port = 'absent',
  $ensure = 'present',
  $check_hostname = 'absent'
) {
  $real_port = $port ? {
    'absent' => $name,
    default  => $port,
  }
  case $check_hostname {
    'absent': {
      nagios::service{"ssh_port_${name}":
        ensure        => $ensure,
        check_command => "check_ssh_port!${real_port}"
      }
    }
    default: {
      nagios::service{"ssh_port_host_${name}":
        ensure        => $ensure,
        check_command => "check_ssh_port_host!${real_port}!${check_hostname}"
      }
    }
  }
}
