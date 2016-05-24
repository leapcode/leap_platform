class shorewall::rules::dns::disable inherits shorewall::rules::dns {
  Shorewall::Rule['net-me-tcp_dns', 'net-me-udp_dns']{
        action  => 'DROP',
    }
}
