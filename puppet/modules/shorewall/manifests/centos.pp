# things needed on centos
class shorewall::centos inherits shorewall::base {
  if $::lsbmajdistrelease > 5 {
    augeas{'enable_shorewall':
      context => '/files/etc/sysconfig/shorewall',
      changes => 'set startup 1',
      lens    => 'Shellvars.lns',
      incl    => '/etc/sysconfig/shorewall',
      require => Package['shorewall'],
      notify  => Service['shorewall'],
    }
  }
}
