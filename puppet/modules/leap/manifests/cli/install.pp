# installs leap_cli on node
class leap::cli::install ( $source = false ) {

  # nokogiri is a dependency gem of leap_cli and
  # needs build tools in order to get compiled
  ensure_packages (['gcc', 'make', 'zlib1g-dev'])
  class { '::ruby':
    install_dev => true,
    require     => [ Package['gcc'], Package['make'], Package['zlib1g-dev'] ]
  }


  if $source {
    # needed for building leap_cli from source
    include ::git
    include ::rubygems


    class { 'bundler::install': install_method => 'package' }

    Class[Ruby] ->
      Class[rubygems] ->
      Class[bundler::install]


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
      user        => 'root',
      environment => 'USER=root',
      refreshonly => true,
      require     => [ Class[bundler::install] ]
    }
  }
  else {
    package { 'leap_cli':
      ensure   => installed,
      provider => gem,
      require  => Class['ruby']
    }
  }
}
