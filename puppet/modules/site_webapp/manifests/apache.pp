class site_webapp::apache {

  $web_api          = hiera('api')
  $api_domain       = $web_api['domain']
  $api_port         = $web_api['port']

  $web_domain       = hiera('domain')
  $domain_name      = $web_domain['name']

  $x509             = hiera('x509')
  $commercial_key   = $x509['commercial_key']
  $commercial_cert  = $x509['commercial_cert']
  $commercial_root  = $x509['commercial_ca_cert']

  include site_config::x509::cert
  include site_config::x509::key
  include site_config::x509::ca

  include x509::variables

  X509::Cert[$site_config::params::cert_name] ~> Service[apache]
  X509::Key[$site_config::params::cert_name]  ~> Service[apache]
  X509::Ca[$site_config::params::ca_name]  ~> Service[apache]

  class { '::apache': no_default_site => true, ssl => true }

  include site_apache::module::headers
  include site_apache::module::rewrite
  include site_apache::module::alias

  class { 'passenger': use_munin => false }

  apache::vhost::file {
    'leap_webapp':
      content => template('site_apache/vhosts.d/leap_webapp.conf.erb')
  }

  apache::vhost::file {
    'api':
      content => template('site_apache/vhosts.d/api.conf.erb')
  }

  x509::key {
    'leap_webapp':
      content => $commercial_key,
      notify  => Service[apache];
  }

  x509::cert {
    'leap_webapp':
      content => $commercial_cert,
      notify  => Service[apache];
  }

  x509::ca {
    'leap_webapp':
      content => $commercial_root,
      notify  => Service[apache];
  }
}
