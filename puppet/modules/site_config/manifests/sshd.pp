class site_config::sshd {
  # configure sshd
  include sshd
  include site_sshd
  # no need for configuring authorized_keys as leap_cli cares for that 
  #$ssh_pubkeys=hiera_hash('ssh_pubkeys')
  #notice($ssh_pubkeys)
  #create_resources('site_sshd::ssh_key', $ssh_pubkeys)
}
