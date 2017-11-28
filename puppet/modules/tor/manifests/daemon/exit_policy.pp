# exit policies
define tor::daemon::exit_policy(
  $accept         = [],
  $reject         = [],
  $reject_private = 1,
  $ensure         = present ) {

  concat::fragment { "07.exit_policy.${name}":
    ensure  => $ensure,
    content => template('tor/torrc.exit_policy.erb'),
    order   => 07,
    target  => $tor::daemon::config_file,
  }
}

