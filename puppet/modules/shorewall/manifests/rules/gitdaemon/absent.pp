class shorewall::rules::gitdaemon::absent inherits shorewall::rules::gitdaemon {
  Shorewall::Rule['net-me-tcp_gitdaemon']{
    ensure => absent,
  }
}
