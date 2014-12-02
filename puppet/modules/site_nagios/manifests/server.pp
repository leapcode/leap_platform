class site_nagios::server inherits nagios::base {

  # First, purge old nagios config (see #1467)
  class { 'site_nagios::server::purge': }

  $nagios_hiera     = hiera('nagios')
  $nagiosadmin_pw   = htpasswd_sha1($nagios_hiera['nagiosadmin_pw'])
  $nagios_hosts     = $nagios_hiera['hosts']
  $domains_internal = $nagios_hiera['domains_internal']

  include nagios::base
  include nagios::defaults::commands
  include nagios::defaults::contactgroups
  include nagios::defaults::contacts
  include nagios::defaults::templates
  include nagios::defaults::timeperiods
  include nagios::defaults::plugins

  class { 'nagios':
    # don't manage apache class from nagios, cause we already include
    # it in site_apache::common
    httpd              => 'absent',
    allow_external_cmd => true,
    stored_config      => false,
  }

  file { '/etc/apache2/conf.d/nagios3.conf':
    ensure => link,
    target => '/usr/share/doc/nagios3-common/examples/apache2.conf',
    notify => Service['apache']
  }

  include site_apache::common
  include site_apache::module::headers

  File ['nagios_htpasswd'] {
    source  => undef,
    content => "nagiosadmin:${nagiosadmin_pw}",
    mode    => '0640',
  }


  # deploy serverside plugins
  file { '/usr/lib/nagios/plugins/check_openvpn_server.pl':
    source => 'puppet:///modules/nagios/plugins/check_openvpn_server.pl',
    mode   => '0755',
    owner  => 'nagios',
    group  => 'nagios',
  }

  create_resources ( site_nagios::add_host_services, $nagios_hosts )

  include site_nagios::server::apache
  include site_check_mk::server
  include site_shorewall::monitor

  augeas {
    'logrotate_nagios':
      context => '/files/etc/logrotate.d/nagios/rule',
      changes => [ 'set file /var/log/nagios3/nagios.log', 'set rotate 7',
        'set schedule daily', 'set compress compress',
        'set missingok missingok', 'set ifempty notifempty',
        'set copytruncate copytruncate' ]
  }

  ::site_nagios::server::hostgroup { $domains_internal: }
}
