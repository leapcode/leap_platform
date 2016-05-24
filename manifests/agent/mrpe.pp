class check_mk::agent::mrpe {
  # check_mk can use standard nagios plugins using
  # a wrapper called mrpe
  # see http://mathias-kettner.de/checkmk_mrpe.html
  # this subclass is provided to be included by checks that use mrpe

  # FIXME: this is Debian specific and should be made more generic
  if !defined(Package['nagios-plugins-basic']) {
    package { 'nagios-plugins-basic':
      ensure => latest,
    }
  }

  # ensure the config file exists, individual checks will add lines to it
  file { '/etc/check_mk/mrpe.cfg':
    ensure  => present,
    require => Package['check-mk-agent']
  }
}
