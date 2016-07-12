#!/bin/sh
WEBROOT="/var/www/htdocs"
#PIDFILE="/var/www/logs/httpd.pid"
echo "#Autogenrated newsyslog.conf\n# logfile_name          owner:group     mode count size when  flags"
find /var/www/logs -name '*_log' -exec perl -e 'print "\n{}\twww:www\t644\t30\t*\t\$D0\tZ" ' \;
find $WEBROOT -name '*_log' -exec perl -e 'print "\n{}\twww:www\t644\t30\t*\t\$D0\tZ" ' \;
perl -e 'print "\t\t \"/bin/sh /opt/bin/restart_apache.sh\"";'
