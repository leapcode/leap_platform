# passenger module
#
# Copyright 2010, Riseup Networks
# Micah Anderson micah(at)riseup.net
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3 as
# published by the Free Software Foundation.

class passenger (
  $use_gems = false, $manage_munin = false,
  $passenger_ensure_version = 'installed',
  $librack_ensure_version = 'installed',
  $passenger_bin_path = '/usr/sbin' )
{
  Class['::apache'] -> Class['passenger']

  if ! $use_gems {

    apache::module { 'passenger':
      ensure       => $passenger_ensure_version,
      package_name => 'libapache2-mod-passenger';
    }

    if !defined(Package['librack-ruby']) {
      if $::lsbdistcodename == 'squeeze' {
        package { 'librack-ruby1.8': ensure => $librack_ensure_version }
      }
      else {
        package { 'ruby-rack':
          ensure => $librack_ensure_version;
        }
      }
    }
  }
  else {
    package {
      'passenger':
        ensure   => $passenger_ensure_version,
        provider => gem;
      'rack':
        ensure   => $librack_ensure_version,
        provider => gem;
    }
  }

  apache::config::file { 'mod_passenger':
    ensure => present,
    source => [ "puppet:///modules/site_passenger/${::fqdn}/mod_passenger.conf",
                'puppet:///modules/site_passenger/mod_passenger.conf',
                'puppet:///modules/passenger/mod_passenger.conf',
              ],
  }

  if $manage_munin {
    if $passenger_memory_munin_config == '' {
      $passenger_memory_munin_config = "user root\nenv.passenger_memory_stats ${passenger_bin_path}/passenger-memory-stats"
    }

    if $passenger_stats_munin_config == '' {
      $passenger_stats_munin_config = "user root\nenv.passenger_status ${passenger_bin_path}/passenger-status"
    }

    munin::plugin::deploy {
      'passenger_memory_stats':
        source => 'passenger/munin/passenger_memory_stats',
        config => $passenger_memory_munin_config;
      'passenger_stats':
        source => 'passenger/munin/passenger_stats',
        config => $passenger_stats_munin_config;
    }
  }

}

