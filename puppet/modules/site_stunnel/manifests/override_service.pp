class site_stunnel::override_service inherits stunnel::debian {

  include site_config::x509::cert
  include site_config::x509::key
  include site_config::x509::ca

  Service[stunnel] {
    subscribe => [
                  Class['Site_config::X509::Key'],
                  Class['Site_config::X509::Cert'],
                  Class['Site_config::X509::Ca'] ]
  }
}
