# == Define: unbound::forward
#
# Creates a forward-zone.  $settings is a hash containing the settings.
# The name of the resource is used as the 'name' of the zone.
#
# === Parameters
#
# [*settings*]
# Hash containing the settings as key value pairs.
#
# === Examples
#
# unbound::forward { 'example.com':
#   settings => {
#     forward-addr => '10.0.0.1',
#   },
# }
#
define unbound::forward (
  $settings,
) {
  include unbound

  $zone_name = { name => "\"${title}\"" }
  $real_settings = { forward-zone => merge($zone_name, $settings) }

  concat::fragment { "unbound ${title}":
    target => $unbound::params::config,
    content => template('unbound/unbound.conf.erb'),
    order => 3,
  }
}
