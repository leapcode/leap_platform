# a pop3 login check
define nagios::service::pop3_login(
  $username,
  $password,
  $warning   = 5,
  $critical  = 10,
  $host      = $::fqdn,
  $host_name = $::fqdn,
  $ensure    = 'present',
){
  nagios::service{
    "pop3_login_${name}":
      ensure => $ensure;
  }

  if $ensure != 'absent' {
    Nagios::Service["pop3_login_${name}"]{
      check_command => "check_pop3_login!${host}!${username}!${password}!${warning}!${critical}",
      host_name     => $host_name,
    }
  }
}
