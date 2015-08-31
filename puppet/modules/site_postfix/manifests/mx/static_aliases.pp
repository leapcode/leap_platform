#
# Defines static, hard coded aliases that are not in the database.
#

class site_postfix::mx::static_aliases {

  $mx = hiera('mx')
  $aliases = $mx['aliases']

  #
  # Predefined aliases.
  #
  # Defines which mail addresses shouldn't be available and where they should
  # fwd
  #
  # TODO: reconcile this with the node property webapp.forbidden_usernames
  #
  # NOTE: if you remove one of these, they will still appear in the
  # /etc/aliases file
  #
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

  #
  # Custom aliases.
  #
  # This does not use the puppet mailalias resource because we want to be able
  # to guarantee the contents of the alias file. This is needed so if you
  # remove an alias from the node's config, it will get removed from the alias
  # file.
  #

  # both alias files must be listed under "alias_database", because once you
  # specify one, then `newaliases` no longer will default to updating
  # "/etc/aliases.db".
  postfix::config {
    'alias_database':
      value => "/etc/aliases, /etc/postfix/custom-aliases";
    'alias_maps':
      value => "hash:/etc/aliases, hash:/etc/postfix/custom-aliases";
  }

  file { '/etc/postfix/custom-aliases':
    content => template('site_postfix/custom-aliases.erb'),
    owner   => root,
    group   => root,
    mode    => 0600,
    notify  => Exec['newaliases']
  }
}
