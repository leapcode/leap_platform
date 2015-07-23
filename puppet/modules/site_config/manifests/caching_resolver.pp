class site_config::caching_resolver {
  tag 'leap_base'

  include site_apt::preferences::unbound

  class { 'unbound':
    root_hints => false,
    anchor     => false,
    ssl        => false,
    settings   => {
      server       => {
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
