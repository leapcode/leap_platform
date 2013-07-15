class site_postfix::mx {

  $domain_hash         = hiera ('domain')
  $domain              = $domain_hash['full_suffix']
  $mx_hash             = hiera('mx')
  $cert_name           = hiera('name')

  $root_mail_recipient = $mx_hash['contact']
  $postfix_smtp_listen = 'all'

  postfix::config {
    'mydestination':
      value => "\$myorigin, localhost, localhost.\$mydomain, ${domain}";
    'smtpd_recipient_restrictions':
      value => 'check_recipient_access tcp:localhost:2244,permit_tls_all_clientcerts,reject_unauth_destination';
    'mailbox_size_limit':   value  => '0';
    'home_mailbox':         value  => 'Maildir/';
    'virtual_alias_maps':   value  => 'tcp:localhost:4242';
    'luser_relay':          value  => 'vmail';
    'local_recipient_maps': value  => '';
    'debug_peer_list':      value => '127.0.0.1';
  }

  include site_postfix::mx::smtpd_checks
  include site_postfix::mx::tls

  user { 'vmail':
    ensure     => present,
    comment    => 'Leap Mailspool',
    home       => '/var/mail/vmail',
    shell      => '/bin/false',
    managehome => true,
  }

  class { 'postfix':
    root_mail_recipient => $root_mail_recipient,
    smtp_listen         => 'all',
    require             => [ X509::Key[$cert_name], X509::Cert[$cert_name],
      User['vmail'] ]
  }
}
