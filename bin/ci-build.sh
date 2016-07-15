#!/bin/sh

. tests/puppet/provider/.platform-test.conf

# create node(s) with unique id so we can run tests in parallel
export TAG="build${CI_BUILD_ID}"
[ -d "${PROVIDERDIR}/tags" ] || mkdir "${PROVIDERDIR}/tags"
echo '{}' > "${PROVIDERDIR}/tags/${TAG}.json"

export IP_SUFFIX_START='100'
#NODES='rewdevcouch1:couchdb,soledad rewdevmx1:mx rewdevvpn1:openvpn,tor rewdevweb1:webapp,monitor rewdevplain1: rewdevstatic1:static'
export NODES="single${TAG}:couchdb,soledad,mx,webapp"
leap-platform-test add_nodes "$NODES"

leap-platform-test -v init_deploy
leap-platform-test -v test
cd tests/puppet/provider
bundle exec leap info
bundle exec leap local destroy
