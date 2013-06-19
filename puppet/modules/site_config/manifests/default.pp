class site_config::default {
  tag 'leap_base'

  $domain_hash = hiera('domain')

  include concat::setup

  # default class, used by all hosts

  include lsb, git

  # configure apt
  include site_apt

  # configure ssh and include ssh-keys
  include site_config::sshd

  # fix dhclient from changing resolver information
  if $::ec2_instance_id {
    include site_config::dhclient
  }

  # configure /etc/resolv.conf
  include site_config::resolvconf

  # configure caching, local resolver
  include site_config::caching_resolver

  # configure /etc/hosts
  class { 'site_config::hosts':
    stage => setup,
  }

  package { [ 'etckeeper' ]:
    ensure => installed,
  }

  # include basic shorewall config
  include site_shorewall::defaults

  Class['git'] -> Vcsrepo<||>

  # include basic shell config
  include site_config::shell
}
