class sshd::client::linux inherits sshd::client::base {
  package {'openssh-clients':
    ensure => $sshd::client::ensure_version,
  }
}
