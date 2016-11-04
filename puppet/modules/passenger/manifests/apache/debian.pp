class passenger::apache::debian inherits passenger::apache::base {

  package { 'libapache2-mod-passenger':
    ensure  => installed,
    require => Package['apache2'],
  }

  file { '/var/www/passenger_buffer':
    ensure  => directory,
    require => [ Package['apache2'], Package['libapache2-mod-passenger'] ],
    owner   => www-data,
    group   => 0,
    mode    => '0600';
  }

  file { '/etc/apache2/conf.d/mod_passenger_custom.conf':
    content => "PassengerUploadBufferDir /var/www/passenger_buffer\n",
    require => File['/var/www/passenger_buffer'],
    notify  => Service['apache2'],
    owner   => root,
    group   => 0,
    mode    => '0644';
  }
}
