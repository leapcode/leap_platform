define nagios::service::pop(
  $ensure = 'present',
  $host = 'absent',
  $port = '110',
  $tls = true,
  $tls_port = '995'
){

  $real_host = $host ? {
    'absent' => $name,
    default => $host
  }

  nagios::service{
    "pop_${name}_${port}":
      ensure => $ensure;
    "pops_${name}_${tls_port}":
      ensure => $tls ? {
        true => $ensure,
        default => 'absent'
        };
  }

  if $ensure != 'absent' {
    Nagios::Service["pop_${name}_${port}"]{
      check_command => "check_pop3!${real_host}!${port}",
    }
    Nagios::Service["pops_${name}_${tls_port}"]{
      check_command => "check_pop3_ssl!${real_host}!${tls_port}",
    }
  }
}
