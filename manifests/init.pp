# == Class: unbound
#
# The unbound class manages unbound, the reqursive caching dns resolver.
# It manages the package, service, configuration file, control keys and
# support files.
#
# The configuration file is concatenated from samples of server et. al.,
# stub-zone and forward-zone.  The latter two are created independently
# from the server settings, by defines which can be used by other classes
# and modules.
#
# Control keys can be created with the unbound-control-setup program,
# and is enabled by default.  These are neccessary to be able to control
# unbound (restart, reload etc) with the unbound-control program.
#
# The auto-trust-anchor-file 'root.key' can be created with the unbound-anchor
# program, and is enabled by default.
#
# The root-hints files named.cache can be managed, but have to be provided by
# the user.  See the documentation in manifests/root_hints.pp for how to proceede.
# This functionality is not enabled by default.
#
# === Parameters
#
# [*settings*]
# Hash containing the settings as key value pairs.
#
# [*ssl*]
# Mange unbound-control certificates?  True or false, true by default.
#
# [*anchor*]
# Manage root.key? True or false, true by default.
#
# [*root_hints*]
# Manage named.cache?  True or false, false by default.
#
# === Examples
#
# class { 'unbound':
#   root_hints => true,
#   settings => {
#     server => {
#       verbosity => '1',
#       interface => [
#         '127.0.0.1',
#         '::1',
#         $::ipaddress,
#       ],
#       outgoing-interface => $::ipaddress,
#       access-control => [
#         '127.0.0.0/8 allow',
#         '::1 allow',
#         '10.0.0.0/8 allow',
#       ],
#       root-hints => '"/var/unbound/etc/named.cache"',
#       private-address => [
#         '10.0.0.0/8',
#         '172.16.0.0/12',
#         '192.168.0.0/16',
#       ],
#       private-domain => "\"$::domain\"",
#       auto-trust-anchor-file => '"/var/unbound/etc/root.key"',
#     },
#     python => { },
#     remote-control => {
#       control-enable => 'yes',
#       control-interface => [
#         '127.0.0.1',
#         '::1',
#       ],
#     },
#   }
# }
#
# See manifests/stub.pp and manifests/forward.pp for examples on how to create
# sub zones and forward zones repectively.
#
class unbound (
  $settings,
  $anchor = true,
  $root_hints = false,
  $ssl = true,
) inherits unbound::params {

  include concat::setup
  include unbound::package
  include unbound::service

  validate_hash($settings)
  validate_bool($anchor)
  validate_bool($root_hints)
  validate_bool($ssl)

  if $anchor {
    include unbound::anchor
  }

  if $root_hints {
    include unbound::root_hints
  }

  if $ssl {
    include unbound::ssl
  }

  $real_settings = $settings

  concat { $unbound::params::config:
    require => Class['unbound::package'],
  }

  concat::fragment { 'unbound server':
    target => $unbound::params::config,
    content => template('unbound/unbound.conf.erb'),
    order => 1,
  }
}
