#!/bin/sh
#
# This script will run create a virtual provider
# and run tests on it.
#
# This script is triggered by .gitlab-ci.yml
#
# It depends on:
#   * leap_platform: in ../..
#   * test provider: in provider/
#   * leap-platform-test: installed in path
#

# leap_platform/tests/platform-ci
export ROOTDIR=$(readlink -f "$(dirname $0)")

# leap_platform/tests/platform-ci/provider
export PROVIDERDIR="${ROOTDIR}/provider"

# leap_platform
export PLATFORMDIR=$(readlink -f "${ROOTDIR}/../..")

# leap_platform/builds
export BUILDSDIR="${PLATFORMDIR}/builds"
export LOCKDIR="${PLATFORMDIR}/builds/lock"
export LOGDIR="${PLATFORMDIR}/builds/log"

export CONTACTS="sysdev@leap.se"
export MAIL_TO=$CONTACTS
export OPTS='--yes'
export FILTER_COMMON=""
export LEAP_CMD="bundle exec leap"

echo "CI directory: ${ROOTDIR}"
echo "Provider directory: ${PROVIDERDIR}"
echo "Platform directory: ${PLATFORMDIR}"

# exit if any commands returns non-zero status
set -e

# create node(s) with unique id so we can run tests in parallel
export TAG="build${CI_BUILD_ID}"
[ -d "${PROVIDERDIR}/tags" ] || mkdir "${PROVIDERDIR}/tags"
echo '{}' > "${PROVIDERDIR}/tags/${TAG}.json"

export IP_SUFFIX_START='100'
export NODES="single${TAG}:couchdb,soledad,mx,webapp,openvpn,tor,monitor,obfsproxy"
leap-platform-test add_nodes "$NODES"
leap-platform-test -v init_deploy
leap-platform-test -v test

cd $PROVIDERDIR
$LEAP_CMD info "${TAG}"
$LEAP_CMD local destroy "${TAG}"
