class site_check_mk::agent::mrpe {
  # check_mk can use standard nagios plugins using
  # a wrapper called mrpe
  # see http://mathias-kettner.de/checkmk_mrpe.html

  package { 'nagios-plugins-basic':
    ensure => latest,
  }

  file { '/etc/check_mk/mrpe.cfg':
    ensure  => present,
    require => Package['check-mk-agent']
  } ->
  file_line { 'Apt':
    line => 'APT    /usr/lib/nagios/plugins/check_apt',
    path => '/etc/check_mk/mrpe.cfg',
  }
}
