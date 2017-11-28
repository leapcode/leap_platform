# map address definition
define tor::daemon::map_address(
  $address    = '',
  $newaddress = '',
  $ensure     = 'present') {

  concat::fragment { "08.map_address.${name}":
    ensure  => $ensure,
    content => template('tor/torrc.map_address.erb'),
    order   => '08',
    target  => $tor::daemon::config_file,
  }
}

