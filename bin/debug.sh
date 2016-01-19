#!/bin/bash
# debug script to be run on remote servers
# called from leap_cli with the 'leap debug' cmd

regexp='(leap|pixelated|stunnel|couch|soledad|haproxy)'

# query facts and filter out private stuff
echo -e '\n\n'
facter | egrep -iv '(^ssh|^uniqueid)'

# query installed versions
echo -e '\n\n'
dpkg -l | egrep "$regexp"


# query running procs
echo -e '\n\n'
ps aux|egrep "$regexp"

echo -e '\n\n'
echo -e "Last deploy:\n"
tail -2 /var/log/leap/deploy-summary.log



