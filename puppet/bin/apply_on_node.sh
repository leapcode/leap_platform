#!/bin/sh

# Script to use on a node for debugging
# Usage: ./apply_on_node.sh <puppet parameters>
#
# Example: ./apply_on_node.sh --debug --verbose

ROOTDIR='/srv/leap'
PLATFORM="$ROOTDIR"
MODULEPATH="$PLATFORM/puppet/modules"
LOG=/var/log/leap.log

# example tags to use
#TAGS='--tags=leap_base,leap_service,leap_slow'
#TAGS='--tags=leap_base,leap_slow'
#TAGS='--tags=leap_base,leap_service'

#######
# Setup
#######

puppet apply -v --confdir $PLATFORM/puppet --libdir $PLATFORM/puppet/lib --modulepath=$MODULEPATH $PLATFORM/puppet/manifests/setup.pp $TAGS $@  |tee $LOG  2>&1 

#########
# site.pp
#########

puppet apply -v --confdir $PLATFORM/puppet --libdir $PLATFORM/puppet/lib --modulepath=$MODULEPATH $PLATFORM/puppet/manifests/site.pp $TAGS $@  |tee $LOG  2>&1 


