# a imap login check
define nagios::service::imap_login(
  $username,
  $password,
  $warning   = 5,
  $critical  = 10,
  $host      = $::fqdn,
  $host_name = $::fqdn,
  $ensure    = 'present',
){
  nagios::service{
    "imap_login_${name}":
      ensure => $ensure;
  }

  if $ensure != 'absent' {
    Nagios::Service["imap_login_${name}"]{
      check_command => "check_imap_login!${host}!${username}!${password}!${warning}!${critical}",
      host_name     => $host_name,
    }
  }
}
