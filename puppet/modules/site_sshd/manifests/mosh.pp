# setup mosh on server
class site_sshd::mosh ( $ensure = present, $ports = '60000-61000' ) {

  package { 'mosh':
    ensure => $ensure
  }

  file { '/etc/shorewall/macro.mosh':
    ensure  => $ensure,
    content => "PARAM   -       -       udp    ${ports}",
    notify  => Exec['shorewall_check'],
    require => Package['shorewall'];
  }

  shorewall::rule { 'net2fw-mosh':
    ensure      => $ensure,
    source      => 'net',
    destination => '$FW',
    action      => 'mosh(ACCEPT)',
    order       => 200;
  }
}
