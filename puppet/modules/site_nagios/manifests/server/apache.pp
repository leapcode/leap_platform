# set up apache for nagios
class site_nagios::server::apache {

  include x509::variables

  include site_config::x509::commercial::cert
  include site_config::x509::commercial::key
  include site_config::x509::commercial::ca

  include apache::module::authn_file
  # "AuthUserFile"
  include apache::module::authz_user
  # "AuthType Basic"
  include apache::module::auth_basic
  # "DirectoryIndex"
  include apache::module::dir
  include apache::module::php5
  include apache::module::cgi

  include apache::module::authn_core

}
