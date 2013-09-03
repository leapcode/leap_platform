class site_config::initial_firewall {

  # This class is intended to setup an initial firewall, before shorewall is
  # configured. The purpose of this is for the rare case where shorewall fails
  # to start, we should not expose services to the public.

  $ssh_config = hiera('ssh')
  $ssh_port   = $ssh_config['port']

  package { 'iptables':
    ensure => present
  }

  file {
    # This firewall enables ssh access, dns lookups and web lookups (for
    # package installation) but otherwise restricts all outgoing and incoming
    # ports
    '/etc/network/ipv4firewall_up.rules':
      content => template('site_config/ipv4firewall_up.rules.erb'),
      owner   => root,
      group   => 0,
      mode    => '0644';

    # This firewall denys all ipv6 traffic - we will need to change this
    # when we begin to support ipv6
    '/etc/network/ipv6firewall_up.rules':
      content => template('site_config/ipv6firewall_up.rules.erb'),
      owner   => root,
      group   => 0,
      mode    => '0644';

    # Run the iptables-restore in if-pre-up so that the network is locked down
    # until the correct interfaces and ips are connected
    '/etc/network/if-pre-up.d/ipv4tables':
      content => "#!/bin/sh\n/sbin/iptables-restore < /etc/network/ipv4firewall_up.rules\n",
      owner   => root,
      group   => 0,
      mode    => '0744';

    # Same as above for IPv6
    '/etc/network/if-pre-up.d/ipv6tables':
      content => "#!/bin/sh\n/sbin/ip6tables-restore < /etc/network/ipv6firewall_up.rules\n",
      owner   => root,
      group   => 0,
      mode    => '0744';
  }

  # Immediately setup these firewall rules, but only if shorewall is not running
  exec {
    'default_ipv4_firewall':
      command   => '/sbin/iptables-restore < /etc/network/ipv4firewall_up.rules',
      logoutput => true,
      unless    => '/etc/init.d/shorewall status',
      require   => File['/etc/network/ipv4firewall_up.rules'];

    'default_ipv6_firewall':
      command   => '/sbin/ip6tables-restore < /etc/network/ipv6firewall_up.rules',
      logoutput => true,
      unless    => '/etc/init.d/shorewall status',
      require   => File['/etc/network/ipv6firewall_up.rules'];
  }
}
