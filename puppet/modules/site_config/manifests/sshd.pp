class site_config::sshd {
  # configure ssh and inculde ssh-keys
  include sshd
  $ssh_pubkeys=hiera_hash('ssh_pubkeys')
  include site_sshd
  notice($ssh_pubkeys)
  create_resources('site_sshd::ssh_key', $ssh_pubkeys)
}
