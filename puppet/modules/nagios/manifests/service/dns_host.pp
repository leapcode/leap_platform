# add a special host and monitor
# it's dns service
define nagios::service::dns_host(
  $check_domain,
  $host_alias,
  $parent,
  $ip
){
  @@nagios_host{$name:
    address => $ip,
    alias   => $host_alias,
    use     => 'generic-host',
    parents => $parent,
  }

  nagios::service::dns{$name:
    host_name    => $name,
    comment      => 'public_ns',
    check_domain => $check_domain,
    ip           => $ip,
  }
}
