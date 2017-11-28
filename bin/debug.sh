#!/bin/bash
# debug script to be run on remote servers
# called from leap_cli with the 'leap debug' cmd

apps='(leap|pixelated|stunnel|couch|soledad)'

facts='(apt_running |^architecture |^augeasversion |^couchdb_.* |^debian_.* |^dhcp_enabled |^domain |^facterversion |^filesystems |^fqdn |^hardwaremodel |^hostname |^interface.* |^ipaddress.* |^is_pe |^is_virtual |^kernel.* |^lib |^lsb.* |^memory.* |^mtu_.* |^netmask.* |^network_.* |^operatingsystem |^os.* |^path |^physicalprocessorcount |^processor.* |^ps |^puppetversion |^root_home |^rsyslog_version |^rubysitedir |^rubyversion |^selinux |^ssh_version |^swapfree.* |^swapsize.* |^type |^virtual)'


# query facts and filter out private stuff
export FACTERLIB="/srv/leap/puppet/modules/apache/lib/facter:/srv/leap/puppet/modules/apt/lib/facter:/srv/leap/puppet/modules/concat/lib/facter:/srv/leap/puppet/modules/couchdb/lib/facter:/srv/leap/puppet/modules/rsyslog/lib/facter:/srv/leap/puppet/modules/site_config/lib/facter:/srv/leap/puppet/modules/sshd/lib/facter:/srv/leap/puppet/modules/stdlib/lib/facter"

facter 2>/dev/null | egrep -i "$facts"

# show leap debian repo used
echo -e '\n\n'
cat /etc/apt/sources.list.d/leap*.list

# query installed versions
echo -e '\n\n'
dpkg -l | egrep "$apps"


# query running procs
echo -e '\n\n'
ps aux|egrep "$apps"

echo -e '\n\n'
echo -e "Last deploy:\n"
tail -2 /var/log/leap/deploy-summary.log
