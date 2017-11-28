#
# If you need something to happen after stunnel is started,
# you can depend on Service['stunnel'] or Class['site_stunnel']
#

class site_stunnel {

  # Install stunnel4 from jessie-backports because the
  # jessie version randonly closes the connection prematurely
  # see https://0xacab.org/leap/platform/issues/8746
  apt::preferences_snippet { 'stunnel4':
    package  => 'stunnel4',
    release  => "${::lsbdistcodename}-backports",
    priority => 999;
  }

  # include the generic stunnel module
  # increase the number of open files to allow for 800 connections
  class { 'stunnel': default_extra => 'ulimit -n 4096' }

  # The stunnel.conf provided by the Debian package is broken by default
  # so we get rid of it and just define our own. See #549384
  if !defined(File['/etc/stunnel/stunnel.conf']) {
    file {
      # this file is a broken config installed by the package
      '/etc/stunnel/stunnel.conf':
        ensure => absent;
    }
  }

  $stunnel = hiera('stunnel')

  # add server stunnels
  create_resources(site_stunnel::servers, $stunnel['servers'])

  # add client stunnels
  $clients = $stunnel['clients']
  $client_sections = keys($clients)
  site_stunnel::clients { $client_sections: }

  # remove any old stunnel logs that are not
  # defined by this puppet run
  file {'/var/log/stunnel4': purge => true;}

  # the default is to keep 356 log files for each stunnel.
  # here we set a more reasonable number.
  augeas {
    'logrotate_stunnel':
      context => '/files/etc/logrotate.d/stunnel4/rule',
      changes => [
        'set rotate 5',
      ]
  }

  include site_stunnel::override_service
}
