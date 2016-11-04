# add vhost folders to logrotation
class apache::logrotate::centos::vhosts inherits apache::logrotate::centos {
    Augeas['logrotate_httpd']{
      changes => [ 'rm /files/etc/logrotate.d/httpd/rule/file',
        'ins file before /files/etc/logrotate.d/httpd/rule/*[1]',
        'ins file before /files/etc/logrotate.d/httpd/rule/*[1]',
        'set /files/etc/logrotate.d/httpd/rule/file[1] /var/log/httpd/*log',
        'set /files/etc/logrotate.d/httpd/rule/file[2] /var/www/vhosts/*/logs/*log' ],
      onlyif => 'get /files/etc/logrotate.d/httpd/rule/file[2] != "/var/www/vhosts/*/logs/*log"',
    }
}
