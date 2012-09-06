#!/bin/sh
# 
# missing: header, licence, usage


apt-get install lsb-release git 

# we need puppet from backports
dist="`lsb_release -cs`"

# enable backports for puppet + facter
[ -f /etc/apt/sources.list.d/$dist-backports.list ] || echo "deb http://backports.debian.org/debian-backports/ $dist-backports main contrib non-free">/etc/apt/sources.list.d/$dist-backports.list

# enable debian testing for ruby-hiera-puppet
cat > /etc/apt/preferences.d/wheezy <<DELIM
Package: *
Pin: release o=Debian,n=wheezy
Pin-Priority: 2
DELIM

apt-get update
apt-get install -y -t $dist-backports facter puppet
apt-get install ruby-hiera-puppet ruby-hiera

puppet apply --modulepath=$PWD/puppet/modules $PWD/puppet/manifests/site.pp $@
