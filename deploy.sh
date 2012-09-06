#!/bin/sh
# 
# missing: header, licence, usage


apt-get install lsb-release git 

# we need puppet from backports
dist="`lsb_release -cs`"
[ -f /etc/apt/sources.list.d/$dist-backports.list ] || echo "deb http://backports.debian.org/debian-backports/ $dist-backports main contrib non-free">/etc/apt/sources.list.d/$dist-backports.list

apt-get update
apt-get install -y -t $dist-backports facter puppet

puppet apply --modulepath=$PWD/puppet/modules $PWD/puppet/manifests/site.pp $@
