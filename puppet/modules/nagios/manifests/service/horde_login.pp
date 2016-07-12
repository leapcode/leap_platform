# a horde login check
define nagios::service::horde_login(
  $password,
  $url,
  $username = $name,
  $ensure   = 'present',
){
  nagios::service{
    "horde_${name}":
      ensure => $ensure;
  }

  if $ensure != 'absent' {
    Nagios::Service["horde_${name}"]{
      check_command => "check_horde_login!${url}!${username}!${password}",
    }
  }
}
