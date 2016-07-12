# deploys the
class sshd::sshkey {

  @@sshkey{$::fqdn:
    ensure => present,
    tag    => 'fqdn',
    type   => 'ssh-rsa',
    key    => $::sshrsakey,
  }

  # In case the node has uses a shared network address,
  # we don't define a sshkey resource using an IP address
  if $sshd::shared_ip == 'no' {
    @@sshkey{$::sshd::sshkey_ipaddress:
      ensure => present,
      tag    => 'ipaddress',
      type   => 'ssh-rsa',
      key    => $::sshrsakey,
    }
  }
}
