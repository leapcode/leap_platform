class site_config::hosts() {

  $hosts = hiera('hosts','')
  $hostname = hiera('name')

  file { "/etc/hostname":
    ensure => present,
    content => $hostname
  }

  exec { "/bin/hostname $hostname":
    subscribe => [ File['/etc/hostname'], File['/etc/hosts'] ]
  }
  
  file { '/etc/hosts':
    content => template('site_config/hosts'),
    mode    => '0644', owner => root, group => root;
  }
}
