class site_tor {
  tag 'leap_service'
  Class['site_config::default'] -> Class['site_tor']

  $tor            = hiera('tor')
  $bandwidth_rate = $tor['bandwidth_rate']
  $tor_type       = $tor['type']
  $nickname       = $tor['nickname']
  $contact_emails = join($tor['contacts'],', ')
  $family         = $tor['family']

  $address        = hiera('ip_address')

  class { 'tor::daemon': }
  tor::daemon::relay { $nickname:
    port           => 9001,
    address        => $address,
    contact_info   => obfuscate_email($contact_emails),
    bandwidth_rate => $bandwidth_rate,
    my_family      => $family
  }

  if ( $tor_type == 'exit'){
    # Only enable the daemon directory if the node isn't also a webapp node
    if ! member($::services, 'webapp') {
      tor::daemon::directory { $::hostname: port => 80 }
    }
  }
  else {
    include site_tor::disable_exit
  }

  include site_shorewall::tor

}
