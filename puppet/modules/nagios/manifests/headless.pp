class nagios::headless {
    class { 'nagios':
      httpd => 'absent',
    }
}
