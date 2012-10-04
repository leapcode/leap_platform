class site_config {
  include apt, lsb, git

  # configure ssh and inculde ssh-keys
  include site_config::sshd

}
