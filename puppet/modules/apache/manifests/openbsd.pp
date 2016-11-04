### openbsd
class apache::openbsd inherits apache::base {
  $config_dir = '/var/www'

  File[vhosts_dir]{
    path => "${config_dir}/vhosts.d",
  }
  File[modules_dir]{
    path => "${config_dir}/conf/modules",
  }
  File[config_dir]{
    path => "${config_dir}/conf.d",
  }
  File[include_dir]{
    path => "${config_dir}/include.d",
  }
  File['htpasswd_dir']{
    group => www,
  }
  File[web_dir]{
    group => daemon,
  }
  file_line{'enable_apache_on_boot':
    path => '/etc/rc.conf.local',
    line => 'httpd flags=""',
  }
  file{'apache_main_config':
    path    => "${config_dir}/conf/httpd.conf",
    source  => ["puppet:///modules/site_apache/config/OpenBSD/${::fqdn}/httpd.conf",
                "puppet:///modules/site_apache/config/OpenBSD/${apache::cluster_node}/httpd.conf",
                'puppet:///modules/site_apache/config/OpenBSD//httpd.conf',
                'puppet:///modules/apache/config/OpenBSD/httpd.conf' ],
    notify  => Service['apache'],
    owner   => root,
    group   => 0,
    mode    => '0644';
  }
  File[default_apache_index] {
    path => '/var/www/htdocs/default/www/index.html',
  }
  file{'/opt/bin/restart_apache.sh':
    source  => 'puppet:///modules/apache/scripts/OpenBSD/bin/restart_apache.sh',
    require => File['/opt/bin'],
    owner   => root,
    group   => 0,
    mode    => '0700';
  }

  ::apache::vhost::webdir{'default':
    datadir => false,
  }

  Service['apache']{
    restart => '/opt/bin/restart_apache.sh',
    status  => 'apachectl status',
    start   => 'apachectl start',
    stop    => 'apachectl stop',
  }
  file{'/opt/bin/apache_logrotate.sh':
    source  => 'puppet:///modules/apache/scripts/OpenBSD/bin/apache_logrotate.sh',
    require => File['/opt/bin'],
    owner   => root,
    group   => 0,
    mode    => '0700';
  }
  cron { 'update_apache_logrotation':
    command => '/bin/sh /opt/bin/apache_logrotate.sh  > /etc/newsyslog_apache.conf',
    minute  => '1',
    hour    => '1',
  }
  cron { 'run_apache_logrotation':
    command => '/usr/bin/newsyslog -f /etc/newsyslog_apache.conf > /dev/null',
    minute  => '10',
  }
}
