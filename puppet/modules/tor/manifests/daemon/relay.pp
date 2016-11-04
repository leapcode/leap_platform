# relay definition
define tor::daemon::relay(
  $port                    = 0,
  $listen_addresses        = [],
  $outbound_bindaddresses  = [],
  $portforwarding          = 0,
  # KB/s, defaulting to using tor's default: 5120KB/s
  $bandwidth_rate          = '',
  # KB/s, defaulting to using tor's default: 10240KB/s
  $bandwidth_burst         = '',
  # KB/s, 0 for no limit
  $relay_bandwidth_rate    = 0,
  # KB/s, 0 for no limit
  $relay_bandwidth_burst   = 0,
  # GB, 0 for no limit
  $accounting_max          = 0,
  $accounting_start        = [],
  $contact_info            = '',
  # TODO: autofill with other relays
  $my_family               = '',
  $address                 = "tor.${::domain}",
  $bridge_relay            = 0,
  $ensure                  = present ) {

  $nickname = $name

  if $outbound_bindaddresses == [] {
    $real_outbound_bindaddresses = []
  } else {
    $real_outbound_bindaddresses = $outbound_bindaddresses
  }

  concat::fragment { '03.relay':
    ensure  => $ensure,
    content => template('tor/torrc.relay.erb'),
    owner   => 'debian-tor',
    group   => 'debian-tor',
    mode    => '0644',
    order   => 03,
    target  => $tor::daemon::config_file,
  }
}
