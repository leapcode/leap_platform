class site_shorewall::sshd {

  $ssh_config     = hiera('ssh')
  $ssh_port       = $ssh_config['port']

  include shorewall

  # define macro for incoming sshd
  file { '/etc/shorewall/macro.leap_sshd':
    content => "PARAM   -       -       tcp    ${ssh_port}",
    notify  => Service['shorewall'],
    require => Package['shorewall']
  }


  shorewall::rule {
      # outside to server
      'net2fw-ssh':
        source      => 'net',
        destination => '$FW',
        action      => 'leap_sshd(ACCEPT)',
        order       => 200;
  }

  # setup a routestopped rule to allow ssh when shorewall is stopped
  shorewall::routestopped { $site_config::params::interface:
    options => "-   tcp   ${ssh_port}"
  }

}
