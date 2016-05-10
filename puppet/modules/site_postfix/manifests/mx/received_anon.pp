# Anonymize the user's home IP from the email headers (Feature #3866) 
class site_postfix::mx::received_anon {

  package { 'postfix-pcre': ensure => installed, require => Package['postfix'] }

  file { '/etc/postfix/checks/received_anon':
    source => 'puppet:///modules/site_postfix/checks/received_anon',
    mode   => '0644',
    owner  => root,
    group  => root,
    notify => Service['postfix']
  }
}
