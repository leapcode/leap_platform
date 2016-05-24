# manifests/libssh2/devel.pp

class sshd::libssh2::devel inherits sshd::libssh2 {
  package{"libssh2-devel.${::architecture}":
    ensure => installed,
  }
}
