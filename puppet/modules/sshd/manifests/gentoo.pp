class sshd::gentoo inherits sshd::linux {
  Package[openssh]{
    category => 'net-misc',
  }
}
