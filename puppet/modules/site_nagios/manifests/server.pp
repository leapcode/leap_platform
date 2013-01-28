class site_nagios::server inherits nagios::base {

  $nagios_hiera=hiera('nagios')
  $nagiosadmin_pw = htpasswd_sha1($nagios_hiera['nagiosadmin_pw'])
  $hosts = $nagios_hiera['hosts']

  include nagios::defaults
  include nagios::base
  #Class ['nagios'] -> Class ['nagios::defaults']
  class {'nagios::apache':
    allow_external_cmd => true,
    stored_config      => false,
    #before             => Class ['nagios::defaults']
  }

  File ['nagios_htpasswd'] {
    source  => undef,
    content => "nagiosadmin:$nagiosadmin_pw",
    mode    => '0640',
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
