class site_tor {
  tag 'leap_service'

  $tor = hiera('tor')
  $bandwidth_rate = $tor['bandwidth_rate']

  $contact_email = hiera('contact_email')

  class { 'tor::daemon': }
  tor::daemon::relay { $::hostname:
    port             => 9001,
    #listen_addresses => '',
    contact_info     => $contact_email,
    bandwidth_rate   => $bandwidth_rate,
  }
  tor::daemon::directory { $::hostname: port => 80 }

  include site_shorewall::tor

}
