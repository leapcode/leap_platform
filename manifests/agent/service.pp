class check_mk::agent::service {
  if ! defined(Service['xinetd']) {
    service { 'xinetd':
      ensure => 'running',
      enable => true,
    }
  }
}
