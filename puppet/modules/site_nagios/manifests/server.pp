class site_nagios::server {
  class {'nagios':
    allow_external_cmd => true
  }
  #include nagios::defaults

}
