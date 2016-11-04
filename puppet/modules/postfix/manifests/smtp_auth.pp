# == Definition: postfix::smtp_auth
#
# Manages content of the /etc/postfix/smtp_auth map.
#
# Requires:
#   - Class["postfix"]
#   - Postfix::Hash["/etc/postfix/smtp_auth"]
#   - file_line (from puppetlab's stdlib module)
#
# Example usage:
#
#  node 'toto.example.com' {
#
#    include postfix
#
#    postfix::hash { '/etc/postfix/smtp_auth':
#      ensure => present,
#    }
#    postfix::config { 'smtp_auth_maps':
#      value => 'hash:/etc/postfix/smtp_auth'
#    }
#    postfix::smtp_auth { 'gmail.com':
#      ensure   => present,
#      user     => 'USER',
#      password => 'PW',
#    }
#  }

define postfix::smtp_auth ($user, $password, $ensure=present) {
  file_line { $name:
    ensure  => $ensure,
    path    => '/etc/postfix/smtp_auth',
    line    => "${name} ${user}:${password}",
    notify  => Exec['generate /etc/postfix/smtp_auth.db'],
    require => Package['postfix'],
  }
}
