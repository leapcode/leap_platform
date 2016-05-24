class nagios::irc_bot::base {
  file {
    '/usr/local/bin/riseup-nagios-client.pl':
      source => 'puppet:///modules/nagios/irc_bot/riseup-nagios-client.pl',
      owner  => root, group => 0, mode => '0755';

    '/usr/local/bin/riseup-nagios-server.pl':
      source => 'puppet:///modules/nagios/irc_bot/riseup-nagios-server.pl',
      owner  => root, group => 0, mode => '0755';

    '/etc/init.d/nagios-nsa':
      content => template("nagios/irc_bot/${::operatingsystem}/nagios-nsa.sh.erb"),
      require => File['/usr/local/bin/riseup-nagios-server.pl'],
      owner   => root, group => 0, mode => '0755';

    '/etc/nagios_nsa.cfg':
      ensure  => present,
      content => template('nagios/irc_bot/nsa.cfg.erb'),
      owner   => nagios, group => 0, mode => '0400',
      notify  => Service['nagios-nsa'];
  }

  package { 'libnet-irc-perl':
    ensure => present,
  }

  service { 'nagios-nsa':
    ensure    => 'running',
    hasstatus => true,
    require   => [ File['/etc/nagios_nsa.cfg'],
                   Package['libnet-irc-perl'],
                   Service['nagios'] ],
  }

  nagios_command {
    'notify-by-irc':
      command_line => '/usr/local/bin/riseup-nagios-client.pl "$HOSTNAME$ ($SERVICEDESC$) $NOTIFICATIONTYPE$ n.$SERVICEATTEMPT$ $SERVICESTATETYPE$ $SERVICEEXECUTIONTIME$s $SERVICELATENCY$s $SERVICEOUTPUT$ $SERVICEPERFDATA$"';
    'host-notify-by-irc':
      command_line => '/usr/local/bin/riseup-nagios-client.pl "$HOSTNAME$ ($HOSTALIAS$) $NOTIFICATIONTYPE$ n.$HOSTATTEMPT$ $HOSTSTATETYPE$ took $HOSTEXECUTIONTIME$s $HOSTOUTPUT$ $HOSTPERFDATA$ $HOSTLATENCY$s"';
  }
}
