class site_shorewall::sshd {

  $ssh_config     = hiera('ssh')
  $ssh_port       = $ssh_config['port']

  include shorewall

  # define macro for incoming sshd
  file { '/etc/shorewall/macro.leap_sshd':
    content => "PARAM   -       -       tcp    $ssh_port",
    notify  => Service['shorewall']
  }


  shorewall::rule {
      # outside to server
      'net2fw-ssh':
        source      => 'net',
        destination => '$FW',
        action      => 'leap_sshd(ACCEPT)',
        order       => 200;
  }
}
