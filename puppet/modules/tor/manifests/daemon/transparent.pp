# Transparent proxy definition
define tor::daemon::transparent(
  $port             = 0,
  $listen_addresses = [],
  $ensure           = present ) {

  concat::fragment { "09.transparent.${name}":
    ensure  => $ensure,
    content => template('tor/torrc.transparent.erb'),
    order   => '09',
    target  => $tor::daemon::config_file,
  }
}

