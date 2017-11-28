# install basic apache modules needed for all services (nagios, webapp)
class site_apache::common {

  include apache::module::rewrite
  include apache::module::env

  class { '::apache':
    no_default_site  => true,
    ssl              => true,
    ssl_cipher_suite => 'HIGH:MEDIUM:!aNULL:!MD5'
  }

  # needed for the mod_ssl config
  include apache::module::mime

  # needed for mod_ssl config
  include apache::module::socache_shmcb
  # generally needed
  include apache::module::mpm_prefork

  include site_apache::common::tls
  include site_apache::common::acme
  include site_apache::common::autorestart

}
