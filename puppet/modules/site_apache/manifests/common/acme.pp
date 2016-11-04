#
# Allows for potential ACME validations (aka Let's Encrypt)
#
class site_apache::common::acme {
  #
  # well, this doesn't work:
  #
  # apache::config::global {'acme.conf':}
  #
  # since /etc/apache2/conf.d is NEVER LOADED BY APACHE
  # https://gitlab.com/shared-puppet-modules-group/apache/issues/11
  #

  file {
    '/etc/apache2/conf-available/acme.conf':
      ensure  => present,
      source  => 'puppet:///modules/site_apache/conf.d/acme.conf',
      require => Package[apache],
      notify  => Service[apache];
    '/etc/apache2/conf-enabled/acme.conf':
      ensure  => link,
      target  => '/etc/apache2/conf-available/acme.conf',
      require => Package[apache],
      notify  => Service[apache];
  }

  file {
    '/srv/acme':
      ensure => 'directory',
      owner => 'www-data',
      group => 'www-data',
      mode => '0755';
    '/srv/acme/ok':
      owner => 'www-data',
      group => 'www-data',
      content => 'ok';
  }
}
