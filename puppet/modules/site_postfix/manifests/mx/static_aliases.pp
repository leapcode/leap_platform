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
  # Custom static virtual aliases.
  #
  exec { 'postmap_virtual_aliases':
    command => '/usr/sbin/postmap /etc/postfix/virtual-aliases',
    refreshonly => true,
    user    => root,
    group   => root,
    require => Package['postfix'],
    subscribe => File['/etc/postfix/virtual-aliases']
  }
  file { '/etc/postfix/virtual-aliases':
    content => template('site_postfix/virtual-aliases.erb'),
    owner   => root,
    group   => root,
    mode    => 0600,
    require => Package['postfix']
  }
}
