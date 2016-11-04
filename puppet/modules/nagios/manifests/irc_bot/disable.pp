class nagios::irc_bot::disable inherits nagios::irc_bot::base {

    Service['nagios-nsa'] {
        ensure => stopped,
        enable => false,
    }

}
