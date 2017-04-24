# extend basic tor things with a snippet based daemon configuration
class tor::daemon::base inherits tor::base {
  # packages, user, group
  Service['tor'] {
    subscribe => Concat[$tor::daemon::config_file],
  }

  Package[ 'tor' ] {
    require => File[$tor::daemon::data_dir],
  }

  group { 'debian-tor':
    ensure    => present,
    allowdupe => false,
  }

  user { 'debian-tor':
    ensure    => present,
    allowdupe => false,
    comment   => 'tor user,,,',
    home      => $tor::daemon::data_dir,
    shell     => '/bin/false',
    gid       => 'debian-tor',
    require   => Group['debian-tor'],
  }

  # directories
  file { $tor::daemon::data_dir:
    ensure  => directory,
    mode    => '0700',
    owner   => 'debian-tor',
    group   => 'debian-tor',
    require => User['debian-tor'],
  }

  file { '/etc/tor':
    ensure  => directory,
    mode    => '0755',
    owner   => 'debian-tor',
    group   => 'debian-tor',
    require => User['debian-tor'],
  }

  file { '/var/lib/puppet/modules/tor':
    ensure  => absent,
    recurse => true,
    force   => true,
  }

  # tor configuration file
  concat { $tor::daemon::config_file:
    mode  => '0600',
    owner => 'debian-tor',
    group => 'debian-tor',
  }

  # config file headers
  concat::fragment { '00.header':
    ensure  => present,
    content => template('tor/torrc.header.erb'),
    order   => 00,
    target  => $tor::daemon::config_file,
  }

  # global configurations
  concat::fragment { '01.global':
    content => template('tor/torrc.global.erb'),
    order   => 01,
    target  => $tor::daemon::config_file,
  }
}
