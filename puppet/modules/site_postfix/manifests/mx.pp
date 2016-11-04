#
# configure mx node
#
class site_postfix::mx {

  $domain_hash         = hiera('domain')
  $domain              = $domain_hash['full_suffix']
  $host_domain         = $domain_hash['full']
  $cert_name           = hiera('name')
  $mynetworks          = join(hiera('mynetworks', ''), ' ')
  $rbls                = suffix(prefix(hiera('rbls', []), 'reject_rbl_client '), ',')

  $root_mail_recipient    = hiera('contacts')
  $postfix_smtp_listen    = 'all'
  $postfix_use_postscreen = 'yes'

  include site_config::x509::cert
  include site_config::x509::key
  include site_config::x509::client_ca::ca
  include site_config::x509::client_ca::key

  postfix::config {
    'mynetworks':
      value => "127.0.0.0/8 [::1]/128 [fe80::]/64 ${mynetworks}";
    # Note: mydestination should not include @domain, because this is
    # used in virtual alias maps.
    'mydestination':
      value => "\$myorigin, localhost, localhost.\$mydomain";
    'myhostname':
      value => $host_domain;
    'mailbox_size_limit':
      value => '0';
    'home_mailbox':
      value => '';
    'virtual_mailbox_domains':
      value => 'deliver.local';
    'virtual_mailbox_base':
      value => '/var/mail/leap-mx';
    'virtual_mailbox_maps':
      value => 'static:Maildir/';
    # Note: virtual-aliases map will take precedence over leap-mx
    # lookup (tcp:localhost)
    'virtual_alias_maps':
      value => 'hash:/etc/postfix/virtual-aliases tcp:localhost:4242';
    'luser_relay':
      value => '';
    # uid and gid are set to an arbitrary hard-coded value here, this
    # must match the 'leap-mx' user/group
    'virtual_uid_maps':
      value => 'static:42424';
    'virtual_gid_maps':
      value => 'static:42424';
    # the two following configs are needed for matching user's client cert
    # fingerprints to enable relaying (#3634). Satellites do not have
    # these configured.
    'smtpd_tls_fingerprint_digest':
      value => 'sha1';
    'relay_clientcerts':
      value => 'tcp:localhost:2424';
    # reject inbound mail to system users
    # see https://leap.se/code/issues/6829
    # this blocks *only* mails to system users, that don't appear in the
    # alias map
    'local_recipient_maps':
      value => '$alias_maps';
    # setup clamav and opendkim on smtpd
    'smtpd_milters':
      value => 'unix:/run/clamav/milter.ctl,unix:/run/opendkim/opendkim.sock';
    # setup opendkim for smtp (non-smtpd) outgoing mail
    'non_smtpd_milters':
      value => 'unix:/run/opendkim/opendkim.sock';
    'milter_default_action':
      value => 'accept';
    # Make sure that the right values are set, these could be set to different
    # things on install, depending on preseed or debconf options
    # selected (see #7478)
    'relay_transport':
      value => 'relay';
    'default_transport':
      value => 'smtp';
    'mailbox_command':
      value => '';
    'header_checks':
      value => '';
    'postscreen_access_list':
      value => 'permit_mynetworks';
    'postscreen_greet_action':
      value => 'enforce';
    # Level of DNS support in the Postfix SMTP client.  Enable DNS lookups
    # (default: empty). When empty, then the legacy "disable_dns_lookups"
    # (default: no) parameter is used. Setting 'smtp_dns_support_level' to
    # enabled sets the previous behavior with the new parameter.  When set to
    # 'dnssec" this enables DNSSEC lookups.
    'smtp_dns_support_level':
      value => 'dnssec';

    # http://www.postfix.org/TLS_README.html#client_tls_dane The "dane" level is
    # a stronger form of opportunistic TLS that is resistant to man in the
    # middle and downgrade attacks when the destination domain uses DNSSEC to
    # publish DANE TLSA records for its MX hosts. If a remote SMTP server has
    # "usable" (see RFC 6698) DANE TLSA records, the server connection will be
    # authenticated. When DANE authentication fails, there is no fallback to
    # unauthenticated or plaintext delivery.
    #
    # If TLSA records are published for a given remote SMTP server (implying TLS
    # support), but are all "unusable" due to unsupported parameters or
    # malformed data, the Postfix SMTP client will use mandatory unauthenticated
    # TLS. Otherwise, when no TLSA records are published, the Postfix SMTP
    # client behavior is the same as with may.
    #
    # This requires postfix to be able to send its DNS queries to a recursive
    # DNS nameserver that is able to validate the signed records
    #
    # Note: we are setting this here, instead of in site_postfix::mx::smtp_tls
    # because the satellites need to have a different value
    'smtp_tls_security_level':
      value => 'dane';
  }

  # Make sure that the cleanup serivce is not chrooted, otherwise it cannot
  # access the opendkim milter socket (#8020)
  exec { 'unset_cleanup_chroot':
    command => '/usr/sbin/postconf -F "cleanup/unix/chroot=n"',
    onlyif  => '/usr/sbin/postconf -h -F "cleanup/unix/chroot" | egrep -qv ^n',
    notify  => Service['postfix'],
    require => File['/etc/postfix/master.cf']
  }

  include ::site_postfix::mx::smtpd_checks
  include ::site_postfix::mx::checks
  include ::site_postfix::mx::smtp_tls
  include ::site_postfix::mx::smtpd_tls
  include ::site_postfix::mx::static_aliases
  include ::site_postfix::mx::rewrite_openpgp_header
  include ::site_postfix::mx::received_anon
  include ::clamav
  include ::opendkim
  include ::postfwd

  # greater verbosity for debugging, take out for production
  #include site_postfix::debug

  case $::operatingsystemrelease {
    /^7.*/: {
      $smtpd_relay_restrictions=''
    }
    default:  {
      $smtpd_relay_restrictions="  -o smtpd_relay_restrictions=\$smtps_relay_restrictions\n"
    }
  }

  $mastercf_tail = "
smtps     inet  n       -       -       -       -       smtpd
  -o smtpd_tls_wrappermode=yes
  -o smtpd_tls_security_level=encrypt
  -o tls_preempt_cipherlist=yes
${smtpd_relay_restrictions}  -o smtpd_recipient_restrictions=\$smtps_recipient_restrictions
  -o smtpd_helo_restrictions=\$smtps_helo_restrictions
  -o smtpd_client_restrictions=
  -o cleanup_service_name=clean_smtps
clean_smtps   unix  n - n - 0 cleanup
  -o header_checks=pcre:/etc/postfix/checks/rewrite_openpgp_headers,pcre:/etc/postfix/checks/received_anon"

  class { 'postfix':
    preseed             => true,
    root_mail_recipient => $root_mail_recipient,
    smtp_listen         => 'all',
    mastercf_tail       => $mastercf_tail,
    use_postscreen      => 'yes',
    require             => [
      Class['Site_config::X509::Key'],
      Class['Site_config::X509::Cert'],
      Class['Site_config::X509::Client_ca::Key'],
      Class['Site_config::X509::Client_ca::Ca'],
      User['leap-mx'] ]
  }
}
