#!/bin/sh -x
# 
# missing: header, license, usage

PUPPET_ENV='--confdir=puppet'

install_prerequisites () {
  PACKAGES='git puppet ruby-hiera-puppet'
  dpkg -l $PACKAGES > /dev/null 2>&1
  if [ ! $? -eq 0 ]
  then 
    apt-get update
    apt-get install $PACKAGES 
  fi

  # lsb is needed for a first puppet run
  puppet apply $PUPPET_ENV --execute 'include lsb'
}

# main 

# commented for testing purposes
# this should be run once on every host on setup
#install_prerequisites

# keep repository up to date
git pull
git submodule init
git submodule update

# run puppet without irritating deprecation warnings
puppet apply $PUPPET_ENV puppet/manifests/site.pp $@ | grep -v 'warning:.*is deprecated'
