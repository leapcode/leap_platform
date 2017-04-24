# DNS definition
define tor::daemon::dns(
  $port             = 0,
  $listen_addresses = [],
  $ensure           = present ) {

  concat::fragment { "08.dns.${name}":
    ensure  => $ensure,
    content => template('tor/torrc.dns.erb'),
    order   => '08',
    target  => $tor::daemon::config_file,
  }
}

