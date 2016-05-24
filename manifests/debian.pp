class sshd::debian inherits sshd::linux {

  Package[openssh]{
    name => 'openssh-server',
  }

  Service[sshd]{
    name       => 'ssh',
    pattern    => 'sshd',
    hasstatus  => true,
    hasrestart => true,
  }
}
