class site_config {
  # default class, use by all hosts

  include apt, lsb, git

  # configure ssh and inculde ssh-keys
  include site_config::sshd

  # configure /etc/resolv.conf
  include site_config::resolvconf
}
