# == Class: unbound::root_hints
#
# The unbound::root_hints class manages the root-hints named.cache file.
# The default mount point is /module_data, which should be installed
# and populated with a the named.cache file before implementing this
# class.  See unbound.conf(5) or the default configuration file for
# how to retrieve such a file.
#
# === Parameters
#
# [*_mount*]
#   Meta parameter for specifying an alternate mount path.
#
# === Examples
#
#  class { 'unbound::root_hints':
#    $_mount = '/modules/unbound',
#  }
#
#  include unbound::root_hints
#
class unbound::root_hints (
    $_mount = "/module_data/unbound",
) {
  include unbound::params

  file { $unbound::params::root_hints:
    ensure => file,
    owner => $unbound::params::user,
    group => $unbound::params::group,
    mode => '0644',
    source => "puppet://${_mount}/named.cache",
    before => Class['unbound::service'],
  }
}
