class nagios::irc_bot(
  $nsa_socket = 'absent',
  $nsa_server,
  $nsa_port = 6667,
  $nsa_nickname,
  $nsa_password = '',
  $nsa_channel,
  $nsa_pidfile = 'absent',
  $nsa_realname = 'Nagios',
  $nsa_usenotices = false,
  $nsa_commandfile = 'absent'
) {
  $real_nsa_socket = $nsa_socket ? {
    'absent' => $::operatingsystem ? {
      centos => '/var/run/nagios-nsa/nsa.socket',
      default => '/var/run/nagios3/nsa.socket'
    },
    default => $nsa_socket,
  }
  $real_nsa_pidfile = $nsa_pidfile ? {
    'absent' => $::operatingsystem ? {
      centos => '/var/run/nagios-nsa/nsa.pid',
      default => '/var/run/nagios3/nsa.pid'
    },
    default => $nsa_pidfile,
  }
  $real_nsa_commandfile = $nsa_commandfile ? {
    'absent' => $::operatingsystem ? {
      centos => '/var/spool/nagios/cmd/nagios.cmd',
      default => '/var/lib/nagios3/rw/nagios.cmd'
    },
    default => $nsa_commandfile,
  }

  case $::operatingsystem {
    centos: {
      include nagios::irc_bot::centos
    }
    debian,ubuntu: {
      include nagios::irc_bot::debian
    }
    default: {
      include nagios::irc_bot::base
    }
  }

  if $nagios::manage_shorewall {
    include shorewall::rules::out::irc
  }
}
