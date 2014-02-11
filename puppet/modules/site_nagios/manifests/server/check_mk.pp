class site_nagios::server::check_mk {

  $ssh_hash = hiera('ssh')
  $pubkey   = $ssh_hash['authorized_keys']['monitor']['key']
  $type     = $ssh_hash['authorized_keys']['monitor']['type']
  $seckey   = $ssh_hash['monitor']['private_key']
  $ssh_port = $ssh_hash['port']

  $nagios_hiera   = hiera_hash('nagios')
  $hosts          = $nagios_hiera['hosts']
  $all_hosts = inline_template("<% @hosts.keys.sort.each do |key| -%>\"<%= key %>\", <% end -%>")

  package { 'check-mk-server':
    ensure => installed,
  }

  # override paths to use the system check_mk rather than OMD
  class { 'check_mk::config':
    site          => '',
    etc_dir       => '/etc',
    nagios_subdir => 'nagios3',
    bin_dir       => '/usr/bin',
    host_groups   => undef,
    require       => Package['check-mk-server']
  }

  Exec['check_mk-reload'] -> Service['nagios']

  file {
    '/etc/check_mk/conf.d/use_ssh.mk':
      content => template('site_check_mk/use_ssh.mk'),
      notify  => Exec['check_mk-refresh'];
    '/etc/check_mk/all_hosts_static':
      content => $all_hosts,
      notify  => Exec['check_mk-refresh'];
    '/etc/check_mk/.ssh':
      ensure => directory;
    '/etc/check_mk/.ssh/id_rsa':
      content => $seckey,
      owner   => 'nagios',
      mode    => '0600';
    '/etc/check_mk/.ssh/id_rsa.pub':
      content => "${type} ${pubkey} monitor",
      owner   => 'nagios',
      mode    => '0644';
  }

}
