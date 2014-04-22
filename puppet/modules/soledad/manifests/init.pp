class soledad {

  group { 'soledad':
    ensure    => present,
    allowdupe => false;
  }

  user { 'soledad':
    ensure    => present,
    allowdupe => false,
    gid       => 'soledad',
    home      => '/srv/leap/soledad',
    require   => Group['soledad'];
  }

  file {
    '/srv/leap/soledad':
      ensure  => directory,
      owner   => 'soledad',
      group   => 'soledad',
      require => User['soledad'];

    '/var/lib/soledad':
      ensure  => directory,
      owner   => 'soledad',
      group   => 'soledad',
      require => User['soledad'];
  }
}
