class check_mk::service {

  if ! defined(Service[$check_mk::http_service_name]) {
    service { $check_mk::http_service_name:
      ensure => 'running',
      enable => true,
    }
  }
  # FIXME: this should get and check $use_ssh before doing this
  if ! defined(Service[xinetd]) {
    service { 'xinetd':
      ensure    => 'running',
      name      => $check_mk::xinitd_service_name,
      hasstatus => false,
      enable    => true,
    }
  }
  service { 'omd':
    ensure => 'running',
    name   => $check_mk::omd_service_name,
    enable => true,
  }
}
