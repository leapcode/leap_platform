# configures nagios on monitoring node
# lint:ignore:inherits_across_namespaces
class site_nagios::server inherits nagios::base {
# lint:endignore

  $nagios_hiera     = hiera('nagios')
  $nagiosadmin_pw   = htpasswd_sha1($nagios_hiera['nagiosadmin_pw'])
  $nagios_hosts     = $nagios_hiera['hosts']
  $nagios_contacts  = hiera('contacts')
  $environment      = $nagios_hiera['environments']

  include nagios::base
  include nagios::defaults::commands
  include nagios::defaults::templates
  include nagios::defaults::timeperiods
  include nagios::pnp4nagios
  include nagios::pnp4nagios::popup

  class { 'nagios':
    # don't manage apache class from nagios, cause we already include
    # it in site_apache::common
    httpd              => 'absent',
    allow_external_cmd => true,
    stored_config      => false,
  }

  # Delete nagios config files provided by packages
  # These don't get parsed by nagios.conf, but are
  # still irritating duplicates to the real config
  # files deployed by puppet in /etc/nagios3/
  file { [
    '/etc/nagios3/conf.d/contacts_nagios2.cfg',
    '/etc/nagios3/conf.d/extinfo_nagios2.cfg',
    '/etc/nagios3/conf.d/generic-host_nagios2.cfg',
    '/etc/nagios3/conf.d/generic-service_nagios2.cfg',
    '/etc/nagios3/conf.d/hostgroups_nagios2.cfg',
    '/etc/nagios3/conf.d/localhost_nagios2.cfg',
    '/etc/nagios3/conf.d/pnp4nagios.cfg',
    '/etc/nagios3/conf.d/services_nagios2.cfg',
    '/etc/nagios3/conf.d/timeperiods_nagios2.cfg' ]:
      ensure => absent;
  }

  # deploy apache nagios3 config
  # until https://gitlab.com/shared-puppet-modules-group/apache/issues/11
  # is not fixed, we need to manually deploy the config file
  file {
    '/etc/apache2/conf-available/nagios3.conf':
      ensure => present,
      source => 'puppet:///modules/nagios/configs/apache2.conf';
    '/etc/apache2/conf-enabled/nagios3.conf':
      ensure  => link,
      target  => '/etc/apache2/conf-available/nagios3.conf';
  }

  include site_apache::common
  include site_webapp::common_vhost
  include apache::module::headers

  File ['nagios_htpasswd'] {
    source  => undef,
    content => "nagiosadmin:${nagiosadmin_pw}",
    mode    => '0640',
  }


  # deploy serverside plugins
  file { '/usr/lib/nagios/plugins/check_openvpn_server.pl':
    source  => 'puppet:///modules/nagios/plugins/check_openvpn_server.pl',
    mode    => '0755',
    owner   => 'nagios',
    group   => 'nagios',
    require => Package['nagios-plugins'];
  }

  create_resources ( site_nagios::add_host_services, $nagios_hosts )

  include site_nagios::server::apache
  include site_check_mk::server
  include site_shorewall::monitor
  include site_nagios::server::icli

  augeas {
    'logrotate_nagios':
      context => '/files/etc/logrotate.d/nagios/rule',
      changes => [ 'set file /var/log/nagios3/nagios.log', 'set rotate 7',
        'set schedule daily', 'set compress compress',
        'set missingok missingok', 'set ifempty notifempty',
        'set copytruncate copytruncate' ]
  }

  create_resources ( site_nagios::server::hostgroup, $environment )
  create_resources ( site_nagios::server::contactgroup, $environment )
  create_resources ( site_nagios::server::add_contacts, $environment )
}
