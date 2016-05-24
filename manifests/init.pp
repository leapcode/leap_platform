# Manage shorewall on your system
class shorewall(
  $startup                    = '1',
  $conf_source                = false,
  $ensure_version             = 'present',
  $tor_transparent_proxy_host = '127.0.0.1',
  $tor_transparent_proxy_port = '9040',
  $tor_user                   = $::operatingsystem ? {
    'Debian' => 'debian-tor',
    default  => 'tor'
  }
) {

  case $::operatingsystem {
    gentoo: { include shorewall::gentoo }
    debian: {
      include shorewall::debian
      $dist_tor_user = 'debian-tor'
    }
    centos: { include shorewall::centos }
    ubuntu: {
    case $::lsbdistcodename {
      karmic: { include shorewall::ubuntu::karmic }
      default: { include shorewall::debian }
      }
    }
    default: {
      notice "unknown operatingsystem: ${::operatingsystem}"
      include shorewall::base
    }
  }

  shorewall::managed_file{
    [
      # See http://www.shorewall.net/3.0/Documentation.htm#Zones
      'zones',
      # See http://www.shorewall.net/3.0/Documentation.htm#Interfaces
      'interfaces',
      # See http://www.shorewall.net/3.0/Documentation.htm#Hosts
      'hosts',
      # See http://www.shorewall.net/3.0/Documentation.htm#Policy
      'policy',
      # See http://www.shorewall.net/3.0/Documentation.htm#Rules
      'rules',
      # See http://www.shorewall.net/3.0/Documentation.htm#Masq
      'masq',
      # See http://www.shorewall.net/3.0/Documentation.htm#ProxyArp
      'proxyarp',
      # See http://www.shorewall.net/3.0/Documentation.htm#NAT
      'nat',
      # See http://www.shorewall.net/3.0/Documentation.htm#Blacklist
      'blacklist',
      # See http://www.shorewall.net/3.0/Documentation.htm#rfc1918
      'rfc1918',
      # See http://www.shorewall.net/3.0/Documentation.htm#Routestopped
      'routestopped',
      # See http://www.shorewall.net/3.0/Documentation.htm#Variables
      'params',
      # See http://www.shorewall.net/3.0/traffic_shaping.htm
      'tcdevices',
      # See http://www.shorewall.net/3.0/traffic_shaping.htm
      'tcrules',
      # See http://www.shorewall.net/3.0/traffic_shaping.htm
      'tcclasses',
      # http://www.shorewall.net/manpages/shorewall-providers.html
      'providers',
      # See http://www.shorewall.net/manpages/shorewall-tunnels.html
      'tunnel',
      # See http://www.shorewall.net/MultiISP.html
      'rtrules',
      # See http://www.shorewall.net/manpages/shorewall-mangle.html
      'mangle',
    ]:;
  }
}
