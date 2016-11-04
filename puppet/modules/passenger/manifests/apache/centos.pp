class passenger::apache::centos inherits passenger::apache::base {

  package { 'mod_passenger':
    ensure  => installed,
    require => Package['apache'],
  }

  file { '/var/www/passenger_buffer':
    ensure  => directory,
    require => [ Package['apache'], Package['mod_passenger'] ],
    owner   => apache,
    group   => 0,
    mode    => '0600';
  }

  file{ '/etc/httpd/conf.d/mod_passenger_custom.conf':
    content => "PassengerUploadBufferDir /var/www/passenger_buffer\n",
    require => File['/var/www/passenger_buffer'],
    notify  => Service['apache'],
    owner   => root,
    group   => 0,
    mode    => '0644';
  }
}
