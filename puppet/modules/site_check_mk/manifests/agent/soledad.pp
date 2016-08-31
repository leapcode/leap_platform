# Configure soledad check_mk checks
class site_check_mk::agent::soledad {

  file { '/etc/check_mk/logwatch.d/soledad.cfg':
    source => 'puppet:///modules/site_check_mk/agent/logwatch/soledad.cfg',
  }

}
