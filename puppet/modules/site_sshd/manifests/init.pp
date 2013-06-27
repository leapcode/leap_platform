class site_sshd {
  $ssh = hiera_hash('ssh')
  $ssh_authorized_keys = $ssh['authorized_keys']

  include site_sshd::authorized_keys

  ##
  ## XTERM TITLE
  ##

  file {'/etc/profile.d/xterm-title.sh':
    source => "puppet://$server/modules/site_sshd/xterm-title.sh",
    owner => root, group => 0, mode => 0644;
  }

  ##
  ## OPTIONAL MOSH SUPPORT
  ##

  $mosh = $ssh['mosh']
  $mosh_ports = $mosh['ports']
  if $ssh['mosh']['enabled'] {
    $mosh_ensure = present
  } else {
    $mosh_ensure = absent
  }

  package { 'mosh':
    ensure => $mosh_ensure;
  }
  file { '/etc/shorewall/macro.mosh':
    ensure  => $mosh_ensure,
    content => "PARAM   -       -       udp    $mosh_ports",
    notify  => Service['shorewall'],
    require => Package['shorewall'];
  }
  shorewall::rule { 'net2fw-mosh':
    ensure      => $mosh_ensure,
    source      => 'net',
    destination => '$FW',
    action      => 'mosh(ACCEPT)',
    order       => 200;
  }
}
