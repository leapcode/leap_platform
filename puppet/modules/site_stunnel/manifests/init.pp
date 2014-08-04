#
# If you need something to happen after stunnel is started,
# you can depend on Service['stunnel'] or Class['site_stunnel']
#

class site_stunnel {

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
}

