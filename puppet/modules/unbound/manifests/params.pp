class unbound::params {
  case $::osfamily {
    'OpenBSD': {
      $package = 'unbound'
      $service = 'unbound'
      $hasstatus = true
      $dir = '/var/unbound/etc'
      $logfile = '/var/unbound/dev/log'
      $control_setup = '/usr/local/sbin/unbound-control-setup'
      $unbound_anchor = '/usr/local/sbin/unbound-anchor'
      $extended_service = 'unbound::service::openbsd'
      $unbound_flags = ''
      $user = '_unbound'
      $group = '_unbound'
    }
    'ubuntu', 'debian': {
      $package = 'unbound'
      $service = 'unbound'
      $hasstatus = true
      $dir = '/etc/unbound'
      $logfile = ''
      $control_setup = '/usr/sbin/unbound-control-setup'
      $unbound_anchor = '/usr/sbin/unbound-anchor'
      $unbound_flags = ''
      $user = 'unbound'
      $group = 'unbound'
    }
    default: {
      fail("Class[unbound] is not supported by your operating system: ${::operatingsystem}")
    }
  }

  $config = "${dir}/unbound.conf"
  $control_certs = [
    "${dir}/unbound_control.key",
    "${dir}/unbound_control.pem",
    "${dir}/unbound_server.key",
    "${dir}/unbound_server.pem",
  ]
  $anchor = "${dir}/root.key"
  $root_hints = "${dir}/named.cache"
}
