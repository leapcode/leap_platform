class sshd::openbsd inherits sshd::base {
  Service[sshd]{
    restart => '/bin/kill -HUP `/bin/cat /var/run/sshd.pid`',
    stop    => '/bin/kill `/bin/cat /var/run/sshd.pid`',
    start   => '/usr/sbin/sshd',
    status  => '/usr/bin/pgrep -f /usr/sbin/sshd',
  }
}
