class site_tor {
  tag 'leap_service'

  $tor = hiera('tor')
  $bandwidth_rate = $tor['bandwidth_rate']
  $tor_type = $tor['type']

  $contact_email = hiera('contact_email')

  class { 'tor::daemon': }
  tor::daemon::relay { $::hostname:
    port             => 9001,
    #listen_addresses => '',
    contact_info     => $contact_email,
    bandwidth_rate   => $bandwidth_rate,
  }

  # we configure the directory later
  #tor::daemon::directory { $::hostname: port => 80 }

  include site_shorewall::tor

  if ( $tor_type == 'exit' ) {
    include site_tor::exit_policy
  }

}
