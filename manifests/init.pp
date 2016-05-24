#
# stunnel puppet module
#
# Copyright 2009, Riseup Networks <micah@riseup.net>
#
#
# This program is free software; you can redistribute
# it and/or modify it under the terms of the GNU
# General Public License version 3 as published by
# the Free Software Foundation.
#
# 1. include stunnel: this will automatically include stunnel::debian,
#    which automatically includes stunnel::linux, which automatically
#    includes stunnel::base
# 2. stunnel::client allows you to configure different /etc/stunnel/*.conf files
#    to provide various stunnel configurations

# TODO: warn on cert/key issues, fail on false accept?

class stunnel (
  $ensure_version = 'present',
  $startboot      = '1',
  $default_extra  = '',
  $cluster        = '' )
{

  case $::operatingsystem {
    debian: { class { 'stunnel::debian': } }
    centos: { class {  'stunnel::centos': } }
    default: { class { 'stunnel::default': } }
  }

  $stunnel_staging = "${::puppet_vardir}/stunnel4"
  $stunnel_compdir = "${stunnel_staging}/configs"

  file {
    [ $stunnel_staging, "${stunnel_staging}/bin" ]:
      ensure => directory,
      owner  => 0,
      group  => 0,
      mode   => '0750';

    "${stunnel_staging}/configs":
      ensure  => directory,
      owner   => 0,
      group   => 0,
      mode    => '0750',
      recurse => true,
      purge   => true,
      force   => true,
      source  => undef;

    "${stunnel_staging}/bin/refresh_stunnel.sh":
      owner   => 0,
      group   => 0,
      mode    => '0755',
      content => template('stunnel/refresh_stunnel.sh.erb');
  }

  exec { 'refresh_stunnel':
    refreshonly => true,
    require     => [ Service['stunnel'], Package['stunnel'], File[$stunnel_compdir] ],
    subscribe   => File[$stunnel_compdir],
    command     => "${stunnel_staging}/bin/refresh_stunnel.sh"
  }
}
