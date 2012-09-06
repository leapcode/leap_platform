#!/bin/sh

puppet apply --modulepath=$PWD/puppet/modules $PWD/puppet/manifests/site.pp $@
