define nagios::service::ping(
    $ensure = present,
    $ping_rate = '!100.0,20%!500.0,60%'
){
  nagios::service{ "check_ping":
    ensure => $ensure,
    check_command => "check_ping${ping_rate}",
  }
}
