# Transparent proxy definition
define tor::daemon::transparent(
  $port             = 0,
  $listen_addresses = [],
  $ensure           = present ) {

  concat::fragment { "09.transparent.${name}":
    ensure  => $ensure,
    content => template('tor/torrc.transparent.erb'),
    owner   => 'debian-tor',
    group   => 'debian-tor',
    mode    => '0644',
    order   => '09',
    target  => $tor::daemon::config_file,
  }
}

