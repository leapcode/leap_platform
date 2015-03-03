class {'apt': }
File['/etc/apt/preferences'] ->
  Exec['refresh_apt'] ->
  Package <| ( title != 'lsb' ) |>

package { [ 'rsync', 'ruby-hiera-puppet', 'git', 'ruby1.9.1-dev', 'rake', 'jq' ]:
  ensure => installed
}

file { '/etc/gemrc':
  content => "---\n:sources:\n  - https://rubygems.org/"
}

vcsrepo { '/srv/leap/leap_cli':
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
  cwd         => '/srv/leap/leap_cli',
  refreshonly => true,
  require     => [ Package['ruby1.9.1-dev'], File['/etc/gemrc'], Package['rake'] ]
}

file { [ '/srv/leap', '/srv/leap/configuration', '/var/log/leap' ]:
  ensure => directory
}

