class sshd::linux inherits sshd::base {
  package{'openssh':
    ensure => $sshd::ensure_version,
  }
  File[sshd_config]{
    require +> Package[openssh],
  }
}
