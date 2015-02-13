#
# Installs apt-fast script.
#

class site_apt::apt_fast {
  $apt_fast_path = apt_fast_path()

  package { 'aria2':
    ensure => latest
  }

  file { '/etc/apt-fast.conf':
    content => template('site_apt/apt-fast.conf.erb'),
    owner   => root,
    group   => root,
    mode    => '0644'
  }

  file { "${apt_fast_path}":
    source  => 'puppet:///modules/site_apt/apt-fast',
    owner   => root,
    group   => root,
    mode    => '0500',
    require => [
      File['/etc/apt-fast.conf'],
      Package['aria2']
    ]
  }
}
