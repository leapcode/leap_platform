class sshd::client::debian inherits sshd::client::linux {
  Package['openssh-clients']{
    name => 'openssh-client',
  }
}
