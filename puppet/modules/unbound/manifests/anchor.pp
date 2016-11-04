# == Class: unbound::anchor
#
# The unbound::anchor class manages the "root.key" file, and creates it with
# the unbound-anchor program.
#
# === Examples
#
# include unbound::anchor
#
class unbound::anchor {
  include unbound::params

  file { $unbound::params::anchor:
    owner => $unbound::params::user,
    group => $unbound::params::group,
    mode => '0644',
    require => Exec[$unbound::params::unbound_anchor],
  }

  exec { $unbound::params::unbound_anchor:
    command => "${unbound::params::unbound_anchor} -a ${unbound::params::anchor}",
    creates => $unbound::params::anchor,
    returns => 1,
    before => Class['unbound::service'],
  }
}
