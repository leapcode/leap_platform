# setup check_mk on the monitoring server
class site_check_mk::server {

  $ssh_hash = hiera('ssh')
  $pubkey   = $ssh_hash['authorized_keys']['monitor']['key']
  $type     = $ssh_hash['authorized_keys']['monitor']['type']
  $seckey   = $ssh_hash['monitor']['private_key']

  $nagios_hiera     = hiera_hash('nagios')
  $hosts            = $nagios_hiera['hosts']

  $all_hosts        = inline_template ('<% @hosts.keys.sort.each do |key| -%><% if @hosts[key]["environment"] != "disabled" %>"<%= @hosts[key]["domain_internal"] %>", <% end -%><% end -%>')
  $domains_internal = $nagios_hiera['domains_internal']
  $environments     = $nagios_hiera['environments']

  package { 'check-mk-server':
    ensure => installed,
  }

  # we don't use check-mk-multisite, and the jessie version
  # of this config file breaks with apache 2.4
  # until https://gitlab.com/shared-puppet-modules-group/apache/issues/11
  # is not fixed, we need to use a generic file type here
  #apache::config::global { 'check-mk-multisite.conf':
  #  ensure => absent
  #}

  file { '/etc/apache2/conf-enabled/check-mk-multisite.conf':
    ensure  => absent,
    require => Package['check-mk-server'];
  }

  # override paths to use the system check_mk rather than OMD
  class { 'check_mk::config':
    site                      => '',
    etc_dir                   => '/etc',
    nagios_subdir             => 'nagios3',
    bin_dir                   => '/usr/bin',
    host_groups               => undef,
    use_storedconfigs         => false,
    inventory_only_on_changes => false,
    require                   => Package['check-mk-server']
  }

  Exec['check_mk-refresh'] ->
    Exec['check_mk-reload'] ->
      Service['nagios']

  file {
    '/etc/check_mk/conf.d/use_ssh.mk':
      content => template('site_check_mk/use_ssh.mk'),
      notify  => Exec['check_mk-refresh'],
      require => Package['check-mk-server'];
    '/etc/check_mk/conf.d/hostgroups.mk':
      content => template('site_check_mk/hostgroups.mk'),
      notify  => Exec['check_mk-refresh'],
      require => Package['check-mk-server'];
    '/etc/check_mk/conf.d/host_contactgroups.mk':
      content => template('site_check_mk/host_contactgroups.mk'),
      notify  => Exec['check_mk-refresh'],
      require => Package['check-mk-server'];
    '/etc/check_mk/conf.d/ignored_services.mk':
      source  => 'puppet:///modules/site_check_mk/ignored_services.mk',
      notify  => Exec['check_mk-refresh'],
      require => Package['check-mk-server'];
    '/etc/check_mk/conf.d/extra_service_conf.mk':
      source  => 'puppet:///modules/site_check_mk/extra_service_conf.mk',
      notify  => Exec['check_mk-refresh'],
      require => Package['check-mk-server'];
    '/etc/check_mk/conf.d/extra_host_conf.mk':
      content => template('site_check_mk/extra_host_conf.mk'),
      notify  => Exec['check_mk-refresh'],
      require => Package['check-mk-server'];

    '/etc/check_mk/all_hosts_static':
      content => $all_hosts,
      notify  => Exec['check_mk-refresh'],
      require => Package['check-mk-server'];

    '/etc/check_mk/.ssh':
      ensure  => directory,
      require => Package['check-mk-server'];
    '/etc/check_mk/.ssh/id_rsa':
      content => $seckey,
      owner   => 'nagios',
      mode    => '0600',
      require => Package['check-mk-server'];
    '/etc/check_mk/.ssh/id_rsa.pub':
      content => "${type} ${pubkey} monitor",
      owner   => 'nagios',
      mode    => '0644',
      require => Package['check-mk-server'];

    # check_icmp must be suid root or called by sudo
    # see https://leap.se/code/issues/5171
    '/usr/lib/nagios/plugins/check_icmp':
      mode    => '4755',
      require => Package['nagios-plugins-basic'];
  }

  include check_mk::agent::local_checks
}
