# some default vars
class nagios::defaults::vars {
  case $nagios::cfgdir {
    '': { $int_cfgdir = $::operatingsystem ? {
            centos => '/etc/nagios',
            default => '/etc/nagios3'
          }
    }
    default: { $int_cfgdir = $nagios::cfgdir }
  }
}
