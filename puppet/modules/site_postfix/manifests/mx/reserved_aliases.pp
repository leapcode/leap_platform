class site_postfix::mx::reserved_aliases {

  postfix::mailalias {
    [ 'postmaster', 'hostmaster', 'domainadmin', 'certmaster', 'ssladmin',
      'arin-admin', 'administrator', 'webmaster', 'www-data', 'www',
      'nobody', 'sys', 'postgresql', 'mysql', 'bin', 'cron', 'lp', 'games',
      'maildrop', 'abuse', 'noc', 'security', 'usenet', 'news', 'uucp',
      'ftp' ]:
      ensure    => present,
      recipient => 'root'
  }

}
