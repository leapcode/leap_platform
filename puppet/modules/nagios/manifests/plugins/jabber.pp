class nagios::plugins::jabber {

    # for check_jabber_login
    require rubygems::xmpp4r

    nagios::plugin { 'check_jabber_login':
         source => 'nagios/plugins/check_jabber_login'
    }
}

