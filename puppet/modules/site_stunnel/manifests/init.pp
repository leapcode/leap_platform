class site_stunnel {

  # include the generic stunnel module
  # increase the number of open files to allow for 800 connections
  $stunnel_default_extra = 'ulimit -n 4096'
  include stunnel

  # The stunnel.conf provided by the Debian package is broken by default
  # so we get rid of it and just define our own. See #549384
  if !defined(File['/etc/stunnel/stunnel.conf']) {
    file {
      # this file is a broken config installed by the package
      '/etc/stunnel/stunnel.conf':
        ensure => absent;
    }
  }
}

