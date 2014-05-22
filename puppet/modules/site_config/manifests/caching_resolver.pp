class site_config::caching_resolver {
  tag 'leap_base'

  # Setup a conf.d directory to place additional unbound configuration files.
  # There must be at least one file in the directory, or unbound will not start,
  # so create an empty placeholder to ensure this.

  # Note: the version of unbound we are working with does not accept a wildcard
  # for an include directive, so we are not able to use this. When we can use
  # the newer unbound, then we will add 'include: /etc/unbound.d/*' to the
  # configuration file

  include site_apt::preferences::unbound

  file {
    # cleanup from how we used to do it
    '/etc/unbound/conf.d':
      force   => true,
      ensure  => absent;

    '/etc/unbound/conf.d/placeholder':
      ensure  => absent;
  }

  class { 'unbound':
    root_hints => false,
    anchor     => false,
    ssl        => false,
    require    => File['/etc/unbound/conf.d/placeholder'],
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
