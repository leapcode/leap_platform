# install basic apache modules needed for all services (nagios, webapp)
class site_apache::common {

  include apache::module::rewrite
  include apache::module::env

  class { '::apache': no_default_site => true, ssl => true }

  # needed for the mod_ssl config
  include apache::module::mime

  # load mods depending on apache version
  if ( $::lsbdistcodename == 'jessie' ) {
    # apache >= 2.4, debian jessie
    # needed for mod_ssl config
    include apache::module::socache_shmcb
    # generally needed
    include apache::module::mpm_prefork
  } else {
    # apache < 2.4, debian wheezy
    # for "Order" directive, i.e. main apache2.conf
    include apache::module::authz_host
  }

  include site_apache::common::tls
}
