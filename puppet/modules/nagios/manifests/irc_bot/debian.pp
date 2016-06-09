class nagios::irc_bot::debian inherits nagios::irc_bot::base {
  exec { "nagios_nsa_init_script":
    command => "/usr/sbin/update-rc.d nagios-nsa defaults",
    unless => "/bin/ls /etc/rc3.d/ | /bin/grep nagios-nsa",
    require => File["/etc/init.d/nagios-nsa"],
    before => Service['nagios-nsa'],
  }
}
