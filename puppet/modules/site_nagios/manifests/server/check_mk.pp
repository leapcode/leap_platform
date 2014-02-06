class site_nagios::server::check_mk {

  # override paths to use the system check_mk rather than OMD
  class { 'check_mk::config':
    site        => '',
    etc_dir     => '/etc',
    bin_dir     => '/usr/bin',
    host_groups => undef
  }

  file {
    '/etc/nagios/check_mk':
      ensure => directory,
      owner  => root,
      group  => root,
      mode   => '0755';

    '/etc/nagios/check_mk/.ssh':
      ensure => directory,
      owner  => root,
      group  => root,
      mode   => '0755';
  }
}
