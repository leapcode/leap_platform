class nagios::command::smtp {
  case $operatingsystem {
    debian,ubuntu: { }  # Debian/Ubuntu already define those checks
    default: {
      nagios_command {
        'check_smtp':
           command_line => '$USER1$/check_smtp -H $ARG1$ -p $ARG2$';
        'check_ssmtp':
           command_line => '$USER1$/check_ssmtp -H $ARG1$ -p $ARG2$ -S';
      }
    }
  }

  nagios_command {
    'check_smtp_tls':
       command_line => '$USER1$/check_smtp -H $ARG1$ -p $ARG2$ -S';
    'check_smtp_cert':
       command_line => '$USER1$/check_smtp -H $ARG1$ -p $ARG2$ -S -D $ARG3$';
    'check_ssmtp_cert':
       command_line => '$USER1$/check_ssmtp -H $ARG1$ -p $ARG2$ -S -D $ARG3$';
  }
}
