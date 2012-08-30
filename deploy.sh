#!/bin/sh

puppet --modulepath=$PWD/modules $PWD/manifests/site.pp $@
