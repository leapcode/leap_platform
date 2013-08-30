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
    'mailbox_size_limit':   value => '0';
    'home_mailbox':         value => 'Maildir/';
    'virtual_alias_maps':   value => 'tcp:localhost:4242';
    'luser_relay':          value => 'vmail';
  }

  include site_postfix::mx::smtpd_checks
  include site_postfix::mx::tls

  # greater verbosity for debugging, take out for production
  include site_postfix::debug

  user { 'vmail':
    ensure     => present,
    comment    => 'Leap Mailspool',
    home       => '/var/mail/vmail',
    shell      => '/bin/false',
    managehome => true,
  }

  class { 'postfix':
    preseed             => true,
    root_mail_recipient => $root_mail_recipient,
    smtp_listen         => 'all',
    mastercf_tail       =>
    "smtps     inet  n       -       -       -       -       smtpd\n
    -o smtpd_tls_wrappermode=yes\n
    -o smtpd_tls_security_level=encrypt\n
    submission inet n        -       n       -       -       smtpd\n
    -o smtpd_tls_security_level=encrypt\n
    -o smtpd_recipient_restrictions=\$submission_recipient_restrictions",
    require             => [ X509::Key[$cert_name], X509::Cert[$cert_name],
                             User['vmail'] ]
  }
}
