class site_config {
  # default class, used by all hosts

  include lsb, git

  # configure apt
  include site_config::apt

  # configure ssh and include ssh-keys
  include site_config::sshd

  # configure /etc/resolv.conf
  include site_config::resolvconf
}
