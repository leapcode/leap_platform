# == Class: unbound::service
#
# Manages the unbound service.  If $unbound::params::extended_service
# is true then OS specific service things are included.
#
# === Examples
#
# include unbound::service
#
class unbound::service {
  include unbound::params

  if $unbound::params::extended_service {
    class { $unbound::params::extended_service: }
  }

  service { $unbound::params::service:
    ensure    => running,
    hasstatus => $unbound::params::hasstatus,
    subscribe => File[$unbound::params::config],
  }
}
