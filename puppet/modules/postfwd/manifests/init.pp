# This class provides rate-limiting for outgoing SMTP, using postfwd
# it is configured with some limits that seem reasonable for a generic
# use-case. Each of the following applies to sasl_authenticated users:
#
# . 150 recipients at a time
# . no more than 50 messages in 60 minutes
# . no more than 250 recipients in 60 minutes.
#
# This class could be easily extended to add overrides to these rules,
# maximum sizes per client, or additional rules
class postfwd {

  ensure_packages(['libnet-server-perl', 'libnet-dns-perl', 'postfwd'])

  file {
    '/etc/default/postfwd':
      source  => 'puppet:///modules/postfwd/postfwd',
      mode    => '0644',
      owner   => root,
      group   => root,
      require => Package['postfwd'];

    '/etc/postfix/postfwd.cf':
      content => template('postfwd/postfwd.cf.erb'),
      mode    => '0644',
      owner   => root,
      group   => root,
      require => File['/etc/postfix'];
  }

  exec {
    '/etc/init.d/postfwd reload':
      refreshonly => true,
      subscribe   => [ File['/etc/postfix/postfwd.cf'],
                       File['/etc/default/postfwd'] ];
  }

  service {
    'postfwd':
      ensure     => running,
      name       => postfwd,
      pattern    => '/usr/sbin/postfwd',
      enable     => true,
      hasrestart => true,
      hasstatus  => false,
      require    => [ File['/etc/default/postfwd'],
                      File['/etc/postfix/postfwd.cf']];
  }
}
