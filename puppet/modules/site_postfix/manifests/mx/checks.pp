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

  # Anonymize the user's home IP from the email headers (Feature #3866)
  package { 'postfix-pcre': ensure => installed }

  file { '/etc/postfix/checks/received_anon':
    source  => 'puppet:///modules/site_postfix/checks/received_anon',
    mode    => '0644',
    owner   => root,
    group   => root,
    notify  => Service['postfix']
  }

  postfix::config {
    'header_checks':
      value   => 'pcre:/etc/postfix/checks/received_anon',
      require => File['/etc/postfix/checks/received_anon'];
  }

}
