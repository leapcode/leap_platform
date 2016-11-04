# setup base apache class
class apache::base {
  file{
    'vhosts_dir':
      ensure  => directory,
      path    => '/etc/apache2/vhosts.d',
      purge   => true,
      recurse => true,
      force   => true,
      notify  => Service['apache'],
      owner   => root,
      group   => 0,
      mode    => '0644';
    'config_dir':
      ensure  => directory,
      path    => '/etc/apache2/conf.d',
      owner   => root,
      group   => 0,
      mode    => '0644';
    'include_dir':
      ensure  => directory,
      path    => '/etc/apache2/include.d',
      purge   => true,
      recurse => true,
      force   => true,
      notify  => Service['apache'],
      owner   => root,
      group   => 0,
      mode    => '0644';
    'modules_dir':
      ensure  => directory,
      path    => '/etc/apache2/modules.d',
      purge   => true,
      recurse => true,
      force   => true,
      notify  => Service['apache'],
      owner   => root,
      group   => 0,
      mode    => '0644';
    'htpasswd_dir':
      ensure  => directory,
      path    => '/var/www/htpasswds',
      purge   => true,
      recurse => true,
      force   => true,
      notify  => Service['apache'],
      owner   => root,
      group   => 'apache',
      mode    => '0640';
    'web_dir':
      ensure  => directory,
      path    => '/var/www',
      owner   => root,
      group   => 0,
      mode    => '0644';
    'default_apache_index':
      path    => '/var/www/localhost/htdocs/index.html',
      content => template('apache/default/default_index.erb'),
      owner   => root,
      group   => 0,
      mode    => '0644';
  } -> anchor{'apache::basic_dirs::ready': }

  apache::config::include{ 'defaults.inc': }
  apache::config::global{ 'git.conf': }
  if !$apache::no_default_site {
    apache::vhost::file { '0-default': }
  }

  service{'apache':
    ensure => running,
    name   => 'apache2',
    enable => true,
  }
}
