# simple mail login check
class nagios::plugins::mail_login {
  nagios::plugin {
    'check_imap_login':
      source => 'nagios/plugins/check_imap_login';
    'check_pop3_login':
      source => 'nagios/plugins/check_pop3_login';
  }
}

