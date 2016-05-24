# socks definition
define tor::daemon::socks(
  $port = 0,
  $listen_addresses = [],
  $policies = [] ) {

  concat::fragment { '02.socks':
    content => template('tor/torrc.socks.erb'),
    owner   => 'debian-tor',
    group   => 'debian-tor',
    mode    => '0644',
    order   => 02,
    target  => $tor::daemon::config_file,
  }
}
