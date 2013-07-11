class site_config::files {

  file { '/srv/leap':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0711'
  }

}