class site_postfix::mx {

  $domain_hash         = hiera ('domain')
  $domain              = $domain_hash['full_suffix']
  $host_domain         = $domain_hash['full']
  $cert_name           = hiera('name')
  $mynetworks          = join(hiera('mx_nodes'), ' ')

  $root_mail_recipient = hiera ('contacts')
  $postfix_smtp_listen = 'all'

  include site_config::x509::cert
  include site_config::x509::key
  include site_config::x509::client_ca::ca
  include site_config::x509::client_ca::key

  postfix::config {
    'mynetworks':
      value => "127.0.0.0/8 [::1]/128 [fe80::]/64 ${mynetworks}";
    'mydestination':
      value => "\$myorigin, localhost, localhost.\$mydomain, ${domain}";
    'myhostname':
      value => $host_domain;
    'mailbox_size_limit':
      value => '0';
    'home_mailbox':
      value => 'Maildir/';
    'virtual_alias_maps':
      value => 'tcp:localhost:4242';
    'luser_relay':
      value => 'vmail';
    'smtpd_tls_received_header':
      value => 'yes';
  }

  include site_postfix::mx::smtpd_checks
  include site_postfix::mx::checks
  include site_postfix::mx::smtp_tls
  include site_postfix::mx::smtpd_tls
  include site_postfix::mx::reserved_aliases

  # greater verbosity for debugging, take out for production
  #include site_postfix::debug

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
    "smtps     inet  n       -       -       -       -       smtpd
  -o smtpd_tls_wrappermode=yes
  -o smtpd_tls_security_level=encrypt
  -o smtpd_recipient_restrictions=\$smtps_recipient_restrictions
  -o smtpd_helo_restrictions=\$smtps_helo_restrictions",
    require             => [
      Class['Site_config::X509::Key'],
      Class['Site_config::X509::Cert'],
      Class['Site_config::X509::Client_ca::Key'],
      Class['Site_config::X509::Client_ca::Ca'],
      User['vmail'] ]
  }
}
