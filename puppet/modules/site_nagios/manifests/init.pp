class site_nagios  {
  tag 'leap_service'
  Class['site_config::default'] -> Class['site_nagios']

  include site_nagios::server
}
