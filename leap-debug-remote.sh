#!/bin/sh
# debug script to be run on remote servers

regexp='(leap|stunnel|couch|soledad|haproxy)'

find /etc/leap/

echo

ls -la /srv/leap/

echo


dpkg -l | egrep "$regexp"

echo

ps aux|egrep "$regexp"

echo

cat /etc/hosts
