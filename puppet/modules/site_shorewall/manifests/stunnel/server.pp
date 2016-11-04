#
# Allow all incoming connections to stunnel server port
#

define site_shorewall::stunnel::server($port) {

  include site_shorewall::defaults

  file { "/etc/shorewall/macro.stunnel_server_${name}":
    content => "PARAM   -       -       tcp    ${port}",
    notify  => Exec['shorewall_check'],
    require => Package['shorewall']
  }
  shorewall::rule {
    "net2fw-stunnel-server-${name}":
      source      => 'net',
      destination => '$FW',
      action      => "stunnel_server_${name}(ACCEPT)",
      order       => 200;
  }

}