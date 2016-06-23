# deploy local caching resolver
class site_config::caching_resolver {
  tag 'leap_base'

  # We need to make sure Package['bind9'] isn't installed because when it is, it
  # keeps unbound from running. Some base debian installs will install bind9,
  # and then start it, so unbound will never get properly started. So this will
  # make sure bind9 is removed before.
  package { 'bind9':
    ensure => absent
  }
  file { [ '/etc/default/bind9', '/etc/bind/named.conf.options' ]:
    ensure => absent
  }

  class { 'unbound':
    root_hints => false,
    anchor     => false,
    ssl        => false,
    require    => Package['bind9'],
    settings   => {
      server => {
        verbosity      => '1',
        interface      => [ '127.0.0.1', '::1' ],
        port           => '53',
        hide-identity  => 'yes',
        hide-version   => 'yes',
        harden-glue    => 'yes',
        access-control => [ '127.0.0.0/8 allow', '::1 allow' ]
      }
    }
  }

  concat::fragment { 'unbound glob include':
    target  => $unbound::params::config,
    content => "include: /etc/unbound/unbound.conf.d/*.conf\n\n",
    order   => 10
  }
}
