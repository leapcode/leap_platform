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
  },
  $zones                      = {},
  $zones_defaults             = {},
  $interfaces                 = {},
  $interfaces_defaults        = {},
  $hosts                      = {},
  $hosts_defaults             = {},
  $policy                     = {},
  $policy_defaults            = {},
  $rules                      = {},
  $rules_defaults             = {},
  $rulesections               = {},
  $rulesections_defaults      = {},
  $masq                       = {},
  $masq_defaults              = {},
  $proxyarp                   = {},
  $proxyarp_defaults          = {},
  $nat                        = {},
  $nat_defaults               = {},
  $blacklist                  = {},
  $blacklist_defaults         = {},
  $rfc1918                    = {},
  $rfc1918_defaults           = {},
  $routestopped               = {},
  $routestopped_defaults      = {},
  $params                     = {},
  $params_defaults            = {},
  $tcdevices                  = {},
  $tcdevices_defaults         = {},
  $tcrules                    = {},
  $tcrules_defaults           = {},
  $tcclasses                  = {},
  $tcclasses_defaults         = {},
  $tunnels                    = {},
  $tunnels_defaults           = {},
  $rtrules                    = {},
  $rtrules_defaults           = {},
  $daily_check                = true,
) {

  case $::operatingsystem {
    'Gentoo': { include ::shorewall::gentoo }
    'Debian','Ubuntu': { include ::shorewall::debian }
    'CentOS': { include ::shorewall::centos }
    default: {
      notice "unknown operatingsystem: ${::operatingsystem}"
      include ::shorewall::base
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

  create_resources('shorewall::zone',$zones,$zones_defaults)
  create_resources('shorewall::interface',$interfaces,$interfaces_defaults)
  create_resources('shorewall::host',$hosts,$hosts_defaults)
  create_resources('shorewall::policy',$policy,$policy_defaults)
  create_resources('shorewall::rule',$rules,$rules_defaults)
  create_resources('shorewall::rule_section',$rulesections,$rulesections_defaults)
  create_resources('shorewall::masq',$masq,$masq_defaults)
  create_resources('shorewall::proxyarp',$proxyarp,$proxyarp_defaults)
  create_resources('shorewall::nat',$nat,$nat_defaults)
  create_resources('shorewall::blacklist',$blacklist,$blacklist_defaults)
  create_resources('shorewall::rfc1918',$rfc1918,$rfc1918_defaults)
  create_resources('shorewall::routestopped',$routestopped,
    $routestopped_defaults)
  create_resources('shorewall::params',$params,$params_defaults)
  create_resources('shorewall::tcdevices',$tcdevices,$tcdevices_defaults)
  create_resources('shorewall::tcrules',$tcrules,$tcrules_defaults)
  create_resources('shorewall::tcclasses',$tcclasses,$tcclasses_defaults)
  create_resources('shorewall::tunnel',$tunnels,$tunnels_defaults)
  create_resources('shorewall::rtrules',$rtrules,$rtrules_defaults)
}
