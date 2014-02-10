class site_sshd::known_hosts ($hosts) {
  # these owner and permissions seem odd to me, but it is what is defined
  # in modules/sshd/manifests/client/base.pp, so we are going to stick with it.
  file { '/etc/ssh/ssh_known_hosts':
    ensure  => present,
    owner   => root,
    group   => 0,
    mode    => '0644',
    content => template('site_sshd/ssh_known_hosts.erb');
  }
}
