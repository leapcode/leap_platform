### debian
class apache::debian inherits apache::package {
  $config_dir = '/etc/apache2'

  Package[apache] {
    name => 'apache2',
  }
  File[vhosts_dir] {
    path => "${config_dir}/sites-enabled",
  }
  File[modules_dir] {
    path => "${config_dir}/mods-enabled",
  }
  File[htpasswd_dir] {
    path   => '/var/www/htpasswds',
    group  => 'www-data',
  }
  File[default_apache_index] {
    path => '/var/www/index.html',
  }
  file { 'apache_main_config':
    path    => "${config_dir}/apache2.conf",
    source  => [ "puppet:///modules/site_apache/config/Debian.${::lsbdistcodename}/${::fqdn}/apache2.conf",
                "puppet:///modules/site_apache/config/Debian/${::fqdn}/apache2.conf",
                "puppet:///modules/site_apache/config/Debian.${::lsbdistcodename}/apache2.conf",
                'puppet:///modules/site_apache/config/Debian/apache2.conf',
                "puppet:///modules/apache/config/Debian.${::lsbdistcodename}/${::fqdn}/apache2.conf",
                "puppet:///modules/apache/config/Debian/${::fqdn}/apache2.conf",
                "puppet:///modules/apache/config/Debian.${::lsbdistcodename}/apache2.conf",
                'puppet:///modules/apache/config/Debian/apache2.conf' ],
    require => Package['apache'],
    notify  => Service['apache'],
    owner   => root,
    group   => 0,
    mode    => '0644';
  }
  apache::config::global{ 'charset': }
  apache::config::global{ 'security': }
  file { 'default_debian_apache_vhost':
    ensure  => absent,
    path    => '/etc/apache2/sites-enabled/000-default',
  }
}

