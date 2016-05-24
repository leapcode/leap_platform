### gentoo
class apache::gentoo inherits apache::package {
  $config_dir = '/etc/apache2'

  # needs module gentoo
  gentoo::etcconfd {
    'apache2':
      require => Package['apache'],
      notify  => Service['apache'],
  }
  Package['apache']{
    category => 'www-servers',
  }
  File[vhosts_dir]{
    path => "${config_dir}/vhosts.d",
  }
  File[modules_dir]{
    path => "${config_dir}/modules.d",
  }

  apache::gentoo::module{
    '00_default_settings':;
    '00_error_documents':;
  }
  apache::config::file { 'default_vhost.include':
      source      => 'apache/vhosts.d/default_vhost.include',
      destination => "${config_dir}/vhosts.d/default_vhost.include",
  }

  # set the default for the ServerName
  file{"${config_dir}/modules.d/00_default_settings_ServerName.conf":
      content => "ServerName ${::fqdn}\n",
      require => Package[apache],
      owner   => root,
      group   => 0,
      mode    => '0644';
  }
}

