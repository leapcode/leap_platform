# set up users, group and directories for soledad-server
# although the soledad users are already created by the
# soledad-server package
class soledad {

  group { 'soledad':
    ensure => present,
    system => true,
  }

  user { 'soledad':
    ensure    => present,
    system    => true,
    gid       => 'soledad',
    home      => '/srv/leap/soledad',
    require   => Group['soledad'];
  }

  user { 'soledad-admin':
    ensure  => present,
    system  => true,
    gid     => 'soledad',
    home    => '/srv/leap/soledad',
    require => Group['soledad'];
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
