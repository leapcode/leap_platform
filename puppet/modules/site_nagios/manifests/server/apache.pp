class site_nagios::server::apache {
  include x509::variables
  include site_config::x509::commercial::cert
  include site_config::x509::commercial::key
  include site_config::x509::commercial::ca

}
