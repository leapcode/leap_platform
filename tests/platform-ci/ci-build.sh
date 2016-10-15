#!/bin/bash
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
#   * AWS credentials as environment variables:
#     * `AWS_ACCESS_KEY`
#     * `AWS_SECRET_KEY`
#   * ssh private key used to login to remove vm
#     * `SSH_PRIVATE_KEY`
#
# Todo:
#   - Running locally works fine, now use it in gitlab CI ( which ssh-key ? create cloud.json from env vars )
#   - Speed up vm boot if possible ( right now 3-4mins )

# exit if any commands returns non-zero status
set -e

# leap_platform/tests/platform-ci
# shellcheck disable=SC2086
ROOTDIR=$(readlink -f "$(dirname $0)")

# leap_platform/tests/platform-ci/provider
PROVIDERDIR="${ROOTDIR}/provider"

# leap_platform
PLATFORMDIR=$(readlink -f "${ROOTDIR}/../..")

LEAP_CMD="/usr/local/bin/bundle exec leap -v2 --yes"

# create node(s) with unique id so we can run tests in parallel
NAME="citest${CI_BUILD_ID}"
# when using gitlab-runner locally, CI_BUILD_ID is always 1 which
# will conflict with running/terminating AWS instances in subsequent runs
# therefore we pick a random number in this case
[ "$CI_BUILD_ID" -eq "1" ] && NAME+="000${RANDOM}"

TAG='single'
SERVICES='couchdb,soledad,mx,webapp,tor,monitor'
SEEDS='sources.platform.apt.basic:http://deb.leap.se/experimental-0.9 sources.webapp.revision:develop sources.nickserver.revision:master'


#
# Main
#


/bin/echo "CI directory: ${ROOTDIR}"
/bin/echo "Provider directory: ${PROVIDERDIR}"
/bin/echo "Platform directory: ${PLATFORMDIR}"
cd "$PROVIDERDIR"

# Ensure we don't output secret stuff to console even when running in verbose mode with -x
set +x

# Create cloud.json needed for `leap vm` commands using AWS credentials
which jq || ( apt-get update -y && apt-get install jq -y )
/usr/bin/jq ".platform_ci.auth |= .+ {\"aws_access_key_id\":\"$AWS_ACCESS_KEY\", \"aws_secret_access_key\":\"$AWS_SECRET_KEY\"}" < cloud.json.template > cloud.json

# Configure ssh keypair
[ -d ~/.ssh ] || /bin/mkdir ~/.ssh
/bin/echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_rsa
/bin/chmod 600 ~/.ssh/id_rsa
/bin/cp users/gitlab-runner/gitlab-runner_ssh.pub ~/.ssh/id_rsa.pub

[ -d "./tags" ] || mkdir "./tags"
/bin/echo "{\"environment\": \"$TAG\"}" | /usr/bin/json_pp > "${PROVIDERDIR}/tags/${TAG}.json"

$LEAP_CMD vm status "$TAG"
# shellcheck disable=SC2086
$LEAP_CMD vm add "$NAME" services:"$SERVICES" tags:"$TAG" $SEEDS
$LEAP_CMD compile "$TAG"
$LEAP_CMD vm status "$TAG"

$LEAP_CMD node init "$TAG"
$LEAP_CMD info "${TAG}"

# Deploy and test
$LEAP_CMD deploy "$TAG"
$LEAP_CMD test "$TAG"

# if everything succeeds, destroy the vm
$LEAP_CMD vm rm "${TAG}"
[ -f "nodes/${NAME}.json" ] && /bin/rm "nodes/${NAME}.json"
