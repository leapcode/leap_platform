# installs leap_cli on node
class leap::cli::install ( $source = false ) {
  if $source {
    # needed for building leap_cli from source
    include ::git
    include ::site_config::ruby::dev

    vcsrepo { '/srv/leap/cli':
      ensure   => present,
      force    => true,
      revision => 'develop',
      provider => 'git',
      source   => 'https://leap.se/git/leap_cli.git',
      owner    => 'root',
      group    => 'root',
      notify   => Exec['install_leap_cli'],
      require  => Package['git']
    }

    exec { 'install_leap_cli':
      command     => '/usr/bin/rake build && /usr/bin/rake install',
      cwd         => '/srv/leap/cli',
      refreshonly => true,
      require     => [ Package['ruby-dev'], File['/etc/gemrc'], Package['rake'] ]
    }
  }
  else {
    package { 'leap_cli':
      ensure   => installed,
      provider => gem
    }
  }
}
