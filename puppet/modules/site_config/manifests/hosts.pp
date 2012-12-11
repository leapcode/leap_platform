class site_config::hosts {

  file { '/etc/hosts':
    content => template('site_config/hosts'),
    mode    => '0644', owner => root, group => root;
  }
}
