# Configure ip forwarding for shorewall
class site_shorewall::ip_forward {
  include augeas
  augeas { 'enable_ip_forwarding':
    changes => 'set /files/etc/shorewall/shorewall.conf/IP_FORWARDING Yes',
    lens    => 'Shellvars.lns',
    incl    => '/etc/shorewall/shorewall.conf',
    notify  => Exec['shorewall_check'],
    require => [ Class[augeas], Package[shorewall] ];
  }
}
