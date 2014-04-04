class site_check_mk::agent::package::perl_plugin  {
  package { 'libnagios-plugin-perl':
    ensure => installed,
  }
}
