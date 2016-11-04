class nagios::irc_bot::centos inherits nagios::irc_bot::base {
  Package['libnet-irc-perl']{
    name => 'perl-Net-IRC',
  }

  Service['nagios-nsa']{
    enable => true,
  }
}
