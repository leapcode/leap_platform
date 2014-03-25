class site_config::setup {

  #
  # this is applied before each run of site.pp
  #
  #$services = ''

  Exec { path => '/usr/bin:/usr/sbin/:/bin:/sbin:/usr/local/bin:/usr/local/sbin' }

  include site_config::params

  include concat::setup
  include stdlib

  # configure /etc/hosts
  class { 'site_config::hosts':
    stage => setup,
  }

  include site_config::initial_firewall

  include site_apt

  package { 'facter':
    ensure  => latest,
    require => Exec['refresh_apt']
  }

  # if squid_deb_proxy_client is set to true, install and configure
  # squid_deb_proxy_client for apt caching
  if hiera('squid_deb_proxy_client', false) {
    include site_squid_deb_proxy::client
  }

  # shorewall is installed/half-configured during setup.pp (Bug #3871)
  # we need to include shorewall::interface{eth0} in setup.pp so
  # packages can be installed during main puppetrun, even before shorewall
  # is configured completly
  if ( $::site_config::params::environment == 'local' ) {
    include site_config::vagrant
  }

  # if class site_custom::setup exists, include it.
  # possibility for users to define custom puppet recipes
  if defined( '::site_custom::setup') {
    include ::site_custom::setup
  }

}
