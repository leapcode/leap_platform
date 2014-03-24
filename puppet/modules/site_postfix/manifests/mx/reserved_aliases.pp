# Defines which mail addresses shouldn't be available and where they should fwd
class site_postfix::mx::reserved_aliases {

  postfix::mailalias {
    [ 'abuse', 'admin', 'arin-admin', 'administrator', 'bin', 'cron',
      'certmaster', 'domainadmin', 'games', 'ftp', 'hostmaster', 'lp',
      'maildrop', 'mysql', 'news', 'nobody', 'noc', 'postmaster', 'postgresql',
      'security', 'ssladmin', 'sys', 'usenet', 'uucp', 'webmaster', 'www',
      'www-data',
    ]:
      ensure    => present,
      recipient => 'root'
  }

}
