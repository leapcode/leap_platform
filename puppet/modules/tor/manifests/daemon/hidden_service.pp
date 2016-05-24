# hidden services definition
define tor::daemon::hidden_service(
  $ports    = [],
  $data_dir = $tor::daemon::data_dir,
  $ensure   = present ) {

  concat::fragment { "05.hidden_service.${name}":
    ensure  => $ensure,
    content => template('tor/torrc.hidden_service.erb'),
    owner   => 'debian-tor',
    group   => 'debian-tor',
    mode    => '0644',
    order   => 05,
    target  => $tor::daemon::config_file,
  }
}

