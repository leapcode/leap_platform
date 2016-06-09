class sshd::client::base {
  # this is needed because the gid might have changed
  file { '/etc/ssh/ssh_known_hosts':
    ensure => present,
    mode   => '0644',
    owner  => root,
    group  => 0;
  }

  # Now collect all server keys
  case $sshd::client::shared_ip {
    no:  { Sshkey <<||>> }
    yes: { Sshkey <<| tag == fqdn |>> }
  }
}
