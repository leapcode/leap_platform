# == Class: unbound::ssl
#
# unbound::ssl creates ssl certificates for controlling unbound with unbound-control,
# using the unbound-control-setup program.  Furthermore, the class manages the mode and user of the certificates themselves.
#
# === Examples
#
#  include unbound::ssl
#
class unbound::ssl {
  include unbound::params

  file { $unbound::params::control_certs:
    owner => $unbound::params::user,
    group => $unbound::params::gruop,
    mode => '0440',
    require => Exec[$unbound::params::control_setup],
  }

  exec { $unbound::params::control_setup:
    command => "${unbound::params::control_setup} -d ${unbound::params::dir}",
    creates => $unbound::params::control_certs,
    before => Class['unbound::service'],
  }
}
