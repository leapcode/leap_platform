class site_nagios::server {

  $nagios_hiera=hiera('nagios')
  $nagiosadmin_pw = $nagios_hiera['nagiosadmin_pw']
  $hosts = $nagios_hiera['hosts']

  include nagios::defaults
  include nagios::base
  #Class ['nagios'] -> Class ['nagios::defaults']
  class {'nagios::apache':
    allow_external_cmd => true,
    stored_config      => false,
    #before             => Class ['nagios::defaults']
  }

  site_nagios::add_host {$hosts:}
}
