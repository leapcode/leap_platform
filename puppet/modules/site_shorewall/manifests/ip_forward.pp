class site_shorewall::ip_forward {
  include augeas
  augeas { 'enable_ip_forwarding':
    changes => 'set /files/etc/shorewall/shorewall.conf/IP_FORWARDING Yes',
    lens    => 'Shellvars.lns',
    incl    => '/etc/shorewall/shorewall.conf',
    notify  => Service[shorewall],
    require => [ Class[augeas], Package[shorewall] ];
  }
}
