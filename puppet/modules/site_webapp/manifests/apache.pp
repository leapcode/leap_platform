class site_webapp::apache {

  $web_api          = hiera('api')
  $api_domain       = $web_api['domain']
  $api_port         = $web_api['port']

  $web_domain       = hiera('domain')
  $domain_name      = $web_domain['name']

  include x509::variables
  include site_config::x509::commercial::cert
  include site_config::x509::commercial::key
  include site_config::x509::commercial::ca

  Class['Site_config::X509::Commercial::Key'] ~> Service[apache]
  Class['Site_config::X509::Commercial::Cert'] ~> Service[apache]
  Class['Site_config::X509::Commercial::Ca'] ~> Service[apache]

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

}
