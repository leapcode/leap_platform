# == Class: unbound::package
#
# Manages the unbound package.
#
# === Examples
#
# include unbound::package
#
class unbound::package {
  include unbound::params

  package { $unbound::params::package:
    ensure => installed,
  }
}
