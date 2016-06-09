# control definition
define tor::daemon::control(
  $port                            = 0,
  $hashed_control_password         = '',
  $cookie_authentication           = 0,
  $cookie_auth_file                = '',
  $cookie_auth_file_group_readable = '',
  $ensure                          = present ) {

  if $cookie_authentication == '0' and $hashed_control_password == '' and $ensure != 'absent' {
    fail('You need to define the tor control password')
  }

  if $cookie_authentication == 0 and ($cookie_auth_file != '' or $cookie_auth_file_group_readable != '') {
    notice('You set a tor cookie authentication option, but do not have cookie_authentication on')
  }

  concat::fragment { '04.control':
    ensure  => $ensure,
    content => template('tor/torrc.control.erb'),
    owner   => 'debian-tor',
    group   => 'debian-tor',
    mode    => '0600',
    order   => 04,
    target  => $tor::daemon::config_file,
  }
}
