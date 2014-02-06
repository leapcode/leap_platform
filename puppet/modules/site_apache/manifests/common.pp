class site_apache::common {
  # installs x509 cert + key and common config
  # that both nagios + leap webapp use

  $web_domain       = hiera('domain')
  $domain_name      = $web_domain['name']

  include x509::variables
  include site_config::x509::commercial::cert
  include site_config::x509::commercial::key
  include site_config::x509::commercial::ca

  Class['Site_config::X509::Commercial::Key'] ~> Service[apache]
  Class['Site_config::X509::Commercial::Cert'] ~> Service[apache]
  Class['Site_config::X509::Commercial::Ca'] ~> Service[apache]

  include site_apache::module::rewrite

  class { '::apache': no_default_site => true, ssl => true }

  apache::vhost::file {
    'common':
      content => template('site_apache/vhosts.d/common.conf.erb')
  }

}
