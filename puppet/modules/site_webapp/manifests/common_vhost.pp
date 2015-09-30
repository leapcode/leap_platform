class site_webapp::common_vhost {
  # installs x509 cert + key and common config
  # that both nagios + leap webapp use

  include x509::variables
  include site_config::x509::commercial::cert
  include site_config::x509::commercial::key
  include site_config::x509::commercial::ca

  Class['Site_config::X509::Commercial::Key'] ~> Service[apache]
  Class['Site_config::X509::Commercial::Cert'] ~> Service[apache]
  Class['Site_config::X509::Commercial::Ca'] ~> Service[apache]

  apache::vhost::file {
  'common':
    content => template('site_apache/vhosts.d/common.conf.erb')
  }
}
