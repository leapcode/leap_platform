# common things to set up on every node
class site_config::default {
  tag 'leap_base'

  $services    = hiera('services', [])
  $domain_hash = hiera('domain')
  include site_config::params
  include site_config::setup

  # make sure apt is updated before any packages are installed
  include apt::update
  Package { require => Exec['apt_updated'] }

  include site_config::slow

  # default class, used by all hosts

  include lsb, git

  # configure sysctl parameters
  include site_config::sysctl

  # configure ssh and include ssh-keys
  include site_sshd

  # include classes for special environments
  # i.e. openstack/aws nodes, vagrant nodes

  # fix dhclient from changing resolver information
  # facter returns 'true' as string
  # lint:ignore:quoted_booleans
  if $::dhcp_enabled == 'true' {
  # lint:endignore
    include site_config::dhclient
  }

  # configure /etc/resolv.conf
  include site_config::resolvconf

  # configure caching, local resolver
  include site_config::caching_resolver

  # install/configure syslog and core log rotations
  include site_config::syslog

  # provide a basic level of quality entropy
  include haveged

  # install/remove base packages
  include site_config::packages

  # include basic shorewall config
  include site_shorewall::defaults

  Package['git'] -> Vcsrepo<||>

  # include basic shell config
  include site_config::shell

  # set up core leap files and directories
  include site_config::files

  # remove leftovers from previous deploys
  include site_config::remove

  if ! member($services, 'mx') {
    include site_postfix::satellite
  }

  # if class custom exists, include it.
  # possibility for users to define custom puppet recipes
  if defined( '::custom') {
    include ::custom
  }

  include site_check_mk::agent
}
