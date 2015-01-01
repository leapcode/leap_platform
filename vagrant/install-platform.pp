class {'apt': }
File['/etc/apt/preferences'] ->
  Exec['refresh_apt'] ->
    Package <| ( title != 'lsb' ) |>

package { [ 'rsync', 'ruby-hiera-puppet', 'git', 'ruby1.9.1-dev', 'rake', 'jq' ]:
  ensure => installed
}

package { 'leap_cli':
  ensure   => latest,
  provider => 'gem',
  require  => Package['ruby1.9.1-dev']
}

file { [ '/srv/leap', '/srv/leap/configuration', '/var/log/leap' ]:
  ensure => directory
}

