# add vhost folders to logrotation
class apache::logrotate::centos {
    augeas{'logrotate_httpd':
      changes => [ 'rm /files/etc/logrotate.d/httpd/rule/file',
        'ins file before /files/etc/logrotate.d/httpd/rule/*[1]',
        'set /files/etc/logrotate.d/httpd/rule/file[1] /var/log/httpd/*log' ],
      onlyif  => 'get /files/etc/logrotate.d/httpd/rule/file[1] != "/var/log/httpd/*log"',
      require => Package['apache'],
    }
}
