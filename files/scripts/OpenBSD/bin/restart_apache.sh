#!/bin/sh

ignoreout='Processing config'
apachectl restart 2>&1 | (egrep -v -e "_default_ VirtualHost overlap on port 443" -e "$ignoreout" -e "/usr/sbin/apachectl restart: httpd restarted" || true )
sleep 10
apachectl start 2>&1 | (egrep -v -e "_default_ VirtualHost overlap on port 443" -e "$ignoreout" -e "/usr/sbin/apachectl startssl: httpd started" || true )
