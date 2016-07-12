# == Define: unbound::stub
#
# Creates a stub-zone.  $settings is a hash containing the settings.
# The name of the resource is used as the 'name' of the zone.
#
# === Parameters
#
# [*settings*]
# Hash containing the settings as key value pairs.
#
# === Examples
#
# unbound::stub { $::domain:
#   settings => {
#     stub-addr => '192.168.1.1',
#   },
# }
#
define unbound::stub (
  $settings,
) {
  include unbound::params

  $zone_name = { name => "\"${title}\"" }
  $real_settings = { stub-zone => merge($zone_name, $settings) }

  concat::fragment { "unbound ${title}":
    target => $unbound::params::config,
    content => template('unbound/unbound.conf.erb'),
    order => 2,
  }
}
