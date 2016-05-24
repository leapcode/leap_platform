# Bridge definition
define tor::daemon::bridge(
  $ip,
  $port,
  $fingerprint = false,
  $ensure      = present ) {

  concat::fragment { "10.bridge.${name}":
    ensure  => $ensure,
    content => template('tor/torrc.bridge.erb'),
    owner   => 'debian-tor',
    group   => 'debian-tor',
    mode    => '0644',
    order   => 10,
    target  => $tor::daemon::config_file,
  }
}

