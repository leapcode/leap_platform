define sysctl::config ($value, $comment) {

  include sysctl

  augeas { "sysctl_${name}":
    context => '/files/etc/sysctl.conf',
    changes => [ "set ${name} ${value}", "insert #comment before ${name}",
                 "set #comment[last()] '${comment}'" ],
    onlyif  => "get ${name} != ${value}",
    notify  => Exec["sysctl_${name}"],
  }

  exec { "sysctl_${name}":
    command     => '/sbin/sysctl -p',
    subscribe   => File['/etc/sysctl.conf'],
    refreshonly => true,
  }
}
