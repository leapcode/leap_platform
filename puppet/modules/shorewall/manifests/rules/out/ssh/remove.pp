class shorewall::rules::out::ssh::remove inherits shorewall::rules::out::ssh {
  Shorewall::Rule['me-net-tcp_ssh']{
    ensure => absent,
  }
}
