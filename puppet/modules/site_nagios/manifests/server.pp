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

  # deploy serverside plugins
  file { '/usr/lib/nagios/plugins/check_openvpn_server.pl':
    source => 'puppet:///modules/nagios/plugins/check_openvpn_server.pl',
    mode   => '0755',
    owner  => 'nagios',
    group  => 'nagios',
  }

  site_nagios::add_host {$hosts:}
}
