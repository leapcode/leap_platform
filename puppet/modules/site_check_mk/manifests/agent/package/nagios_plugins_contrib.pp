class site_check_mk::agent::package::nagios_plugins_contrib  {
  package { 'nagios-plugins-contrib':
    ensure => installed,
  }
}
