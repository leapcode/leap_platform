class site_config::hosts {

  $hosts = hiera('hosts','')
  $hostname = hiera('name')

  exec { "/bin/hostname $hostname": }

  file { "/etc/hostname":
    ensure => present,
    content => $hostname
  }

  file { '/etc/hosts':
    content => template('site_config/hosts'),
    mode    => '0644', owner => root, group => root;
  }
}
