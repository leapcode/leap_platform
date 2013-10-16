class site_config::syslog {

  class { 'rsyslog::client': log_remote => false, log_local => true }

}

