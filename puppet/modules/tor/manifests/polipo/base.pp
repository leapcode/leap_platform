# manage polipo resources
class tor::polipo::base {
  package{'polipo':
    ensure => present,
  }

  file { '/etc/polipo/config':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    source  => 'puppet:///modules/tor/polipo/polipo.conf',
    require => Package['polipo'],
    notify  => Service['polipo'],
  }

  service { 'polipo':
    ensure  => running,
    enable  => true,
    require => [ Package['polipo'], Service['tor'] ],
  }
}
