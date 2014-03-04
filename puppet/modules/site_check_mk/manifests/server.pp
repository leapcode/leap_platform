class site_check_mk::server {

  $ssh_hash = hiera('ssh')
  $pubkey   = $ssh_hash['authorized_keys']['monitor']['key']
  $type     = $ssh_hash['authorized_keys']['monitor']['type']
  $seckey   = $ssh_hash['monitor']['private_key']

  $nagios_hiera   = hiera_hash('nagios')
  $nagios_hosts   = $nagios_hiera['hosts']

  $hosts          = hiera_hash('hosts')
  $all_hosts      = inline_template ('<% @hosts.keys.sort.each do |key| -%>"<%= @hosts[key]["domain_internal"] %>", <% end -%>')

  package { 'check-mk-server':
    ensure => installed,
  }

  # override paths to use the system check_mk rather than OMD
  class { 'check_mk::config':
    site              => '',
    etc_dir           => '/etc',
    nagios_subdir     => 'nagios3',
    bin_dir           => '/usr/bin',
    host_groups       => undef,
    use_storedconfigs => false,
    require           => Package['check-mk-server']
  }

  Exec['check_mk-reload'] ->
    Exec['check_mk-refresh-inventory-daily'] ->
    Service['nagios']

  file {
    '/etc/check_mk/conf.d/use_ssh.mk':
      content => template('site_check_mk/use_ssh.mk'),
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
