# manage mail checks
class nagios::command::imap_pop3 {
  require ::nagios::plugins::mail_login
  case $::operatingsystem {
    'Debian','Ubuntu': { }  # Debian/Ubuntu already define those checks
    default: {
      nagios_command {
        'check_imap':
          command_line => '$USER1$/check_imap -H $ARG1$ -p $ARG2$';
      }
    }
  }

  nagios_command {
    'check_imap_ssl':
      command_line => '$USER1$/check_imap -H $ARG1$ -p $ARG2$ -S';
    'check_pop3':
      command_line => '$USER1$/check_pop -H $ARG1$ -p $ARG2$';
    'check_pop3_ssl':
      command_line => '$USER1$/check_pop -H $ARG1$ -p $ARG2$ -S';
    'check_managesieve':
      command_line => '$USER1$/check_tcp -H $ARG1$ -p 4190';
    'check_managesieve_legacy':
      command_line => '$USER1$/check_tcp -H $ARG1$ -p 2000';
    'check_imap_login':
      command_line => '$USER1$/check_imap_login -s -H $ARG1$ -u $ARG2$ -p $ARG3$ -w $ARG4$ -c $ARG5$';
    'check_pop3_login':
      command_line => '$USER1$/check_pop3_login -s -H $ARG1$ -u $ARG2$ -p $ARG3$ -w $ARG4$ -c $ARG5$';
  }
}
