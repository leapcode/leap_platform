class site_config::default {
  tag 'leap_base'

  $domain_hash = hiera('domain')
  include site_config::params

  # make sure apt is updated before any packages are installed
  include apt::update
  Package { require => Exec['apt_updated'] }

  include stdlib

  include site_config::slow


  include concat::setup

  # default class, used by all hosts

  include lsb, git

  # configure apt
  include site_apt

  # configure ssh and include ssh-keys
  include site_config::sshd

  # include classes for special environments
  # i.e. openstack/aws nodes, vagrant nodes

  # fix dhclient from changing resolver information
  if $::ec2_instance_id {
    include site_config::dhclient
  }

  if ( $::site_config::params::environment == 'local' ) {
    include site_config::vagrant
  }

  # configure /etc/resolv.conf
  include site_config::resolvconf

  # configure caching, local resolver
  include site_config::caching_resolver

  # configure /etc/hosts
  class { 'site_config::hosts':
    stage => setup,
  }

  # install/configure syslog
  include site_config::syslog

  # install/remove base packages
  include site_config::packages::base

  # include basic shorewall config
  include site_shorewall::defaults

  Class['git'] -> Vcsrepo<||>

  # include basic shell config
  include site_config::shell

  # set up core leap files and directories
  include site_config::files

  # redundant declarations, remove if
  # "Move setup.pp to a subclass (site_config::setup) (Feature #2993)"
  # is solved.

  # if squid_deb_proxy_client is set to true, install and configure
  # squid_deb_proxy_client for apt caching
  if hiera('squid_deb_proxy_client', false) {
    include site_squid_deb_proxy::client
  }

  if $::services !~ /\bmx\b/ {
    include site_postfix::satellite
  }

}
