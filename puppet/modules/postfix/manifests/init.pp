#
# == Class: postfix
#
# This class provides a basic setup of postfix with local and remote
# delivery and an SMTP server listening on the loopback interface.
#
# Parameters:
# - *$smtp_listen*: address on which the smtp service will listen to. defaults to 127.0.0.1
# - *$root_mail_recipient*: who will recieve root's emails. defaults to "nobody"
# - *$anon_sasl*: set $anon_sasl="yes" to hide the originating IP in email
# - *$manage_header_checks*: manage header checks
# - *$manage_tls_policy*: manage tls policy
# - *$manage_transport_regexp*: manage transport regexps
# - *$manage_virtual_regexp*: manage virtual regexps
# - *$tls_fingerprint_digest*: fingerprint digest for tls policy class
# - *$use_amavisd*: set to "yes" to configure amavis
# - *$use_dovecot_lda*: include dovecot declaration at master.cf
# - *$use_schleuder*: whether to include schleuder portion at master.cf
# - *$use_sympa*: whether to include sympa portion at master.cf
# - *$use_firma*: whether to include firma portion at master.cf
# - *$use_mlmmj*: whether to include mlmmj portion at master.cf
# - *$use_submission*: set to "yes" to enable submission section at master.cf
# - *$use_smtps*: set to "yes" to enable smtps section at master.cf
# - *$mastercf_tail*: set this for additional content to be added at the end of master.cf
# - *$inet_interfaces*: which inet interface postfix should listen on
# - *$myorigin*: sets postfix $myorigin configuration
#
# Example usage:
#
#   node "toto.example.com" {
#     class { 'postfix':
#       smtp_listen => "192.168.1.10"
#     }
#   }
#
class postfix(
  $smtp_listen             = '127.0.0.1',
  $root_mail_recipient     = 'nobody',
  $anon_sasl               = 'no',
  $manage_header_checks    = 'no',
  $manage_tls_policy       = 'no',
  $manage_transport_regexp = 'no',
  $manage_virtual_regexp   = 'no',
  $tls_fingerprint_digest  = 'sha1',
  $use_amavisd             = 'no',
  $use_dovecot_lda         = 'no',
  $use_schleuder           = 'no',
  $use_sympa               = 'no',
  $use_firma               = 'no',
  $use_mlmmj               = 'no',
  $use_postscreen          = 'no',
  $use_submission          = 'no',
  $use_smtps               = 'no',
  $mastercf_tail           = '',
  $inet_interfaces         = 'all',
  $myorigin                = $::fqdn,
  $mailname                = $::fqdn,
  $preseed                 = false,
  $default_alias_maps      = true
) {

  case $::operatingsystem {

    'RedHat', 'CentOS': {
      $master_cf_template = 'postfix/master.cf.redhat5.erb'

      # selinux labels differ from one distribution to another
      case $::operatingsystemmajrelease {
        '4':     { $postfix_seltype = 'etc_t' }
        '5':     { $postfix_seltype = 'postfix_etc_t' }
        default: { $postfix_seltype = undef }
      }

      postfix::config {
        'sendmail_path': value => '/usr/sbin/sendmail.postfix';
        'newaliases_path': value => '/usr/bin/newaliases.postfix';
        'mailq_path': value => '/usr/bin/mailq.postfix';
      }
    }

    'Debian': {
      case $::operatingsystemrelease {
        /^5.*/: {
          $master_cf_template = 'postfix/master.cf.debian-5.erb'
        }
        /^6.*/: {
          $master_cf_template = 'postfix/master.cf.debian-6.erb'
        }
        /^7.*/: {
          $master_cf_template = 'postfix/master.cf.debian-7.erb'
        }
        default:  {
          $master_cf_template = "postfix/master.cf.debian-${::operatingsystemmajrelease}.erb"
        }
      }
    }

    'Ubuntu': {
      $master_cf_template = 'postfix/master.cf.debian-sid.erb'
    }

    default: {
      $postfix_seltype    = undef
      $master_cf_template = undef
    }
  }


  # Bootstrap moduledir
  include common::moduledir
  common::module_dir{'postfix': }

  # Include optional classes
  if $anon_sasl == 'yes' {
    include postfix::anonsasl
  }
  # this global variable needs to get parameterized as well
  if $::header_checks == 'yes' {
    include postfix::header_checks
  }
  if $manage_tls_policy == 'yes' {
    class { 'postfix::tlspolicy':
      fingerprint_digest => $tls_fingerprint_digest,
    }
  }
  if $use_amavisd == 'yes' {
    include postfix::amavis
  }
  if $manage_transport_regexp == 'yes' {
    include postfix::transport_regexp
  }
  if $manage_virtual_regexp == 'yes' {
    include postfix::virtual_regexp
  }

  package { 'mailx':
    ensure => installed
  }

  if ( $preseed ) {
    apt::preseeded_package { 'postfix':
      ensure  => installed,
    }
  } else {
    package { 'postfix':
      ensure => installed
    }
  }

  if $::operatingsystem == 'debian' {
    Package[mailx] { name => 'bsd-mailx' }
  }

  service { 'postfix':
    ensure  => running,
    require => Package['postfix'],
  }

  file { '/etc/mailname':
    ensure  => present,
    content => "${::fqdn}\n",
    seltype => $postfix_seltype,
  }

  # Aliases
  file { '/etc/aliases':
    ensure  => present,
    content => "# file managed by puppet\n",
    replace => false,
    seltype => $postfix_seltype,
    notify  => Exec['newaliases'],
  }

  # Aliases
  exec { 'newaliases':
    command     => '/usr/bin/newaliases',
    refreshonly => true,
    require     => Package['postfix'],
    subscribe   => File['/etc/aliases'],
  }

  # Config files
  file { '/etc/postfix/master.cf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template($master_cf_template),
    seltype => $postfix_seltype,
    notify  => Service['postfix'],
    require => Package['postfix'],
  }

  # Config files
  file { '/etc/postfix/main.cf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/postfix/main.cf',
    replace => false,
    seltype => $postfix_seltype,
    notify  => Service['postfix'],
    require => Package['postfix'],
  }

  # Default configuration parameters
  if $default_alias_maps {
    postfix::config {
      'alias_maps': value => 'hash:/etc/aliases';
    }
  }
  postfix::config {
    'myorigin':        value => $myorigin;
    'inet_interfaces': value => $inet_interfaces;
  }

  postfix::mailalias {'root':
    recipient => $root_mail_recipient,
  }
}
