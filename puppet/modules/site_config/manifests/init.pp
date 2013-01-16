class site_config {
  # default class, used by all hosts

  include lsb, git

  # configure apt
  include site_apt


  # configure ssh and include ssh-keys
  include site_config::sshd

  # configure /etc/resolv.conf
  include site_config::resolvconf

  # configure caching, local resolver
  include site_config::caching_resolver
  
  # configure /etc/hosts
  stage { 'initial':
    before => Stage['main'],
  }

  class { 'site_config::hosts':
    stage => initial,
  }

  class { 'site_apt::dist_upgrade':
    stage => initial,
  }
}
