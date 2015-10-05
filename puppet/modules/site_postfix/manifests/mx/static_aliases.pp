#
# Defines static, hard coded aliases that are not in the database.
# These aliases take precedence over the database aliases.
#
# There are three classes of reserved names:
#
# (1) forbidden_usernames:
#     Some usernames are forbidden and cannot be registered.
#     this is defined in node property webapp.forbidden_usernames
#     This is enforced by the webapp.
#
# (2) public aliases:
#     Some aliases for root, and are publicly exposed so that anyone
#     can deliver mail to them. For example, postmaster.
#     These are implemented in the virtual alias map, which takes
#     precedence over the local alias map.
#
# (3) local aliases:
#     Some aliases are only available locally: mail can be delivered
#     to the alias if the mail originates from the local host, or is
#     hostname qualified, but otherwise it will be rejected.
#     These are implemented in the local alias map.
#
# The alias for local 'root' is defined elsewhere. In this file, we
# define the virtual 'root@domain' (which can be overwritten by
# defining an entry for root in node property mx.aliases).
#

class site_postfix::mx::static_aliases {

  $mx = hiera('mx')
  $root_recipients = hiera('contacts')

  #
  # LOCAL ALIASES
  #

  # NOTE: if you remove one of these, they will still appear in the
  # /etc/aliases file
  $local_aliases = [
    'admin', 'administrator', 'bin', 'cron', 'games', 'ftp', 'lp', 'maildrop',
    'mysql', 'news', 'nobody', 'noc', 'postgresql', 'ssladmin', 'sys',
    'usenet', 'uucp', 'www', 'www-data'
  ]

  postfix::mailalias {
    $local_aliases:
      ensure    => present,
      recipient => 'root'
  }

  #
  # PUBLIC ALIASES
  #

  $public_aliases = $mx['aliases']

  $default_public_aliases = {
    'root'          => $root_recipients,
    'abuse'         => 'postmaster',
    'arin-admin'    => 'root',
    'certmaster'    => 'hostmaster',
    'domainadmin'   => 'hostmaster',
    'hostmaster'    => 'root',
    'mailer-daemon' => 'postmaster',
    'postmaster'    => 'root',
    'security'      => 'root',
    'webmaster'     => 'hostmaster',
  }

  $aliases = merge($default_public_aliases, $public_aliases)

  exec { 'postmap_virtual_aliases':
    command     => '/usr/sbin/postmap /etc/postfix/virtual-aliases',
    refreshonly => true,
    user        => root,
    group       => root,
    require     => Package['postfix'],
    subscribe   => File['/etc/postfix/virtual-aliases']
  }
  file { '/etc/postfix/virtual-aliases':
    content => template('site_postfix/virtual-aliases.erb'),
    owner   => root,
    group   => root,
    mode    => '0600',
    require => Package['postfix']
  }
}
