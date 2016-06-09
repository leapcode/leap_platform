# manifests/libssh2.pp

class sshd::libssh2 {
  package{'libssh2':
    ensure => present,
  }
}
