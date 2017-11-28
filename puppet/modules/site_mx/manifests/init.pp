# Configure leap_mx on mx server
class site_mx {
  tag 'leap_service'
  Class['::site_config::default'] -> Class['::site_mx']

  include ::site_config::default
  include ::site_config::x509::cert
  include ::site_config::x509::key
  include ::site_config::x509::ca
  include ::site_config::x509::client_ca::ca
  include ::site_config::x509::client_ca::key

  include ::site_stunnel

  include ::site_postfix::mx
  include ::site_shorewall::mx
  include ::site_shorewall::service::smtp
  include ::leap_mx
  include ::site_check_mk::agent::mx
  # install twisted from jessie backports
  include ::site_apt::preferences::twisted
  # install python-cryptography from jessie backports
  include ::site_apt::preferences::python_cryptography
}
