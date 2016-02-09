class site_postfix::mx::checks {

  file {
    '/etc/postfix/checks':
      ensure  => directory,
      mode    => '0755',
      owner   => root,
      group   => postfix,
      require => Package['postfix'];

    '/etc/postfix/checks/helo_checks':
      content => template('site_postfix/checks/helo_access.erb'),
      mode    => '0644',
      owner   => root,
      group   => root;
  }

  exec {
    '/usr/sbin/postmap /etc/postfix/checks/helo_checks':
      refreshonly => true,
      subscribe   => File['/etc/postfix/checks/helo_checks'];
  }
}
