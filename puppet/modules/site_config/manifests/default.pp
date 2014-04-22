class site_config::default {
  tag 'leap_base'

  $domain_hash = hiera('domain')
  include site_config::params

  # make sure apt is updated before any packages are installed
  include apt::update
  Package { require => Exec['apt_updated'] }

  include site_config::slow

  # default class, used by all hosts

  include lsb, git

  # configure sysctl parameters
  include site_config::sysctl

  # configure ssh and include ssh-keys
  include site_config::sshd

  # include classes for special environments
  # i.e. openstack/aws nodes, vagrant nodes

  # fix dhclient from changing resolver information
  if $::ec2_instance_id {
    include site_config::dhclient
  }

  # configure /etc/resolv.conf
  include site_config::resolvconf

  # configure caching, local resolver
  include site_config::caching_resolver

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

  if $::services !~ /\bmx\b/ {
    include site_postfix::satellite
  }

  # if class site_custom exists, include it.
  # possibility for users to define custom puppet recipes
  if defined( '::site_custom') {
    include ::site_custom
  }

  include site_check_mk::agent
}
