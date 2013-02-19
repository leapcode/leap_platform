class site_ca_daemon::apache {

  $api_domain       = hiera('api_domain')
  $x509             = hiera('x509')
  $commercial_key   = $x509['commercial_key']
  $commercial_cert  = $x509['commercial_cert']
  $commercial_root  = $x509['commercial_ca_cert']
  $api_key          = $x509['key']
  $api_cert         = $x509['cert']
  $api_root         = $x509['ca_cert']

  $apache_no_default_site = true
  include apache::ssl

  apache::module {
    'alias':   ensure => present;
    'rewrite': ensure => present;
    'headers': ensure => present;
  }

  class { 'passenger': use_munin => false }

  apache::vhost::file {
    'leap_ca_daemon':
      content => template('site_apache/vhosts.d/leap_ca_daemon.conf.erb')
  }

  apache::vhost::file {
    'api':
      content => template('site_apache/vhosts.d/api.conf.erb')
  }

  x509::key {
    'leap_ca_daemon':
      content => $commercial_key,
      notify  => Service[apache];

    'leap_api':
      content => $api_key,
      notify  => Service[apache];
  }

  x509::cert {
    'leap_ca_daemon':
      content => $commercial_cert,
      notify  => Service[apache];

    'leap_api':
      content => $api_cert,
      notify  => Service[apache];
  }

  x509::ca {
    'leap_ca_daemon':
      content => $commercial_root,
      notify  => Service[apache];

    'leap_api':
      content => $api_root,
      notify  => Service[apache];
  }
}
