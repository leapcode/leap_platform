class site_config::dhclient {

  # Unfortunately, there does not seem to be a way to reload the dhclient.conf
  # config file, or a convenient way to disable the modifications to
  # /etc/resolv.conf. So the following makes the functions involved noops and
  # ships a script to kill and restart dhclient. See the debian bugs:
  # #681698, #712796

  include site_config::params

  file { '/usr/local/sbin/reload_dhclient':
    owner   => 0,
    group   => 0,
    mode    => '0755',
    content => template('site_config/reload_dhclient.erb');
  }

  exec { 'reload_dhclient':
    refreshonly => true,
    command     => '/usr/local/sbin/reload_dhclient',
    before      => Class['site_config::resolvconf'],
    require     => File['/usr/local/sbin/reload_dhclient'],
  }

  file { '/etc/dhcp/dhclient-enter-hooks.d/disable_resolvconf':
    content => 'make_resolv_conf() { : ; } ; set_hostname() { : ; }',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    notify  => Exec['reload_dhclient'];
  }
}
