#!/bin/sh -x
# 
# missing: header, licence, usage


install_packages () 
{
  apt-get install lsb-release git 

  # we need puppet from backports
  dist="`lsb_release -cs`"

  # enable backports for puppet + facter
  [ -f /etc/apt/sources.list.d/$dist-backports.list ] || echo "deb http://backports.debian.org/debian-backports/ $dist-backports main contrib non-free">/etc/apt/sources.list.d/$dist-backports.list

  # enable debian wheezy for ruby-hiera-puppet
  if [ "$dist" != "wheezy" ] 
  then
    cat > /etc/apt/preferences.d/wheezy <<DELIM
Package: *
Pin: release o=Debian,n=wheezy
Pin-Priority: 2
DELIM
  fi

  apt-get update
  apt-get install -y -t $dist-backports facter puppet
  apt-get install ruby-hiera-puppet ruby-hiera
}

# main 

# commented for testing purposes
#install_packages

puppet apply --confdir=$PWD/puppet $PWD/puppet/manifests/site.pp $@

