class site_config::sshd {
  # configure ssh and inculde ssh-keys
  include sshd
  $ssh_keys=hiera_hash('ssh_keys')
  include site_sshd
  notice($ssh_keys)
  create_resources('site_sshd::ssh_key', $ssh_keys)
}
