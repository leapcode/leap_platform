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

# exit if any commands returns non-zero status
set -e
# because the ci-build is running in a pipe we need to also set the following
# so exit codes will be caught correctly.
set -o pipefail

# Check if scipt is run in debug mode so we can hide secrets
if [[ "$-" =~ 'x' ]]
then
  echo 'Running with xtrace enabled!'
  xtrace=true
else
  echo 'Running with xtrace disabled!'
  xtrace=false
fi

# leap_platform/tests/platform-ci
# shellcheck disable=SC2086
ROOTDIR=$(readlink -f "$(dirname $0)")

# leap_platform
PLATFORMDIR=$(readlink -f "${ROOTDIR}/../..")

# In the gitlab CI pipeline leap is installed in a different
# stage by bundle. To debug you can run a single CI job locally
# so we install leap_cli as gem here.
if /usr/local/bin/bundle exec leap >/dev/null 2>&1
then
  LEAP_CMD() {
    /usr/local/bin/bundle exec leap -v2 --yes "$@"
  }
else
  sudo gem install leap_cli
  LEAP_CMD() {
    leap -v2 --yes "$@"
  }
fi

fail() {
  echo "$*"
  exit 1
}

deploy() {
  LEAP_CMD deploy "$TAG"
}

test() {
  LEAP_CMD test "$TAG"
}

build_from_scratch() {
  # create node(s) with unique id so we can run tests in parallel
  NAME="citest${CI_BUILD_ID:-0}"
  # when using gitlab-runner locally, CI_BUILD_ID is always 1 which
  # will conflict with running/terminating AWS instances in subsequent runs
  # therefore we pick a random number in this case
  [ "${CI_BUILD_ID:-0}" -eq "1" ] && NAME+="000${RANDOM}"

  TAG='single'
  SERVICES='couchdb,soledad,mx,webapp,tor,monitor'

  # leap_platform/tests/platform-ci/provider
  PROVIDERDIR="${ROOTDIR}/provider"
  /bin/echo "Provider directory: ${PROVIDERDIR}"
  cd "$PROVIDERDIR"

  # Create cloud.json needed for `leap vm` commands using AWS credentials
  which jq || ( apt-get update -y && apt-get install jq -y )

  # Dsiable xtrace
  set +x

  [ -z "$AWS_ACCESS_KEY" ]  && fail "\$AWS_ACCESS_KEY  is not set - please provide it as env variable."
  [ -z "$AWS_SECRET_KEY" ]  && fail "\$AWS_SECRET_KEY  is not set - please provide it as env variable."
  [ -z "$SSH_PRIVATE_KEY" ] && fail "\$SSH_PRIVATE_KEY is not set - please provide it as env variable."

  /usr/bin/jq ".platform_ci.auth |= .+ {\"aws_access_key_id\":\"$AWS_ACCESS_KEY\", \"aws_secret_access_key\":\"$AWS_SECRET_KEY\"}" < cloud.json.template > cloud.json
  # Enable xtrace again only if it was set at beginning of script
  [[ $xtrace == true ]] && set -x

  [ -d "./tags" ] || mkdir "./tags"
  /bin/echo "{\"environment\": \"$TAG\"}" | /usr/bin/json_pp > "${PROVIDERDIR}/tags/${TAG}.json"

  pwd

  # remove old cached nodes
  echo "Removing old cached nodes..."
  find nodes -name 'citest*' -exec rm {} \;

  echo "Listing current VM status..."
  LEAP_CMD vm status "$TAG"
  # shellcheck disable=SC2086
  echo "Adding VM $NAME with the services: $SERVICES and the tags: $TAG"
  LEAP_CMD vm add "$NAME" services:"$SERVICES" tags:"$TAG"
  echo "Compiling $TAG..."
  LEAP_CMD compile "$TAG"
  echo "Listing current VM status for TAG: $TAG..."
  LEAP_CMD vm status "$TAG"

  echo "Running leap list..."
  LEAP_CMD list

  echo "Running leap node init on TAG: $TAG"
  LEAP_CMD node init "$TAG"
  echo "Running leap info on $TAG"
  LEAP_CMD info "${TAG}"
}

run() {
  echo "Cloning $1 repo: $2"
    git clone -q --depth 1 "$2"
    cd "$1"
    git rev-parse HEAD
    echo -n "Operating in the $1 directory: "
    pwd
    echo "Listing current node information..."
    LEAP_CMD list
    echo "Attempting a deploy..."
    deploy
    echo "Attempting to run tests..."
    test
}

upgrade_test() {
  # Checkout stable branch containing last release
  # and deploy this
  cd "$PLATFORMDIR"
  git remote add leap https://leap.se/git/leap_platform
  git fetch leap
  git checkout -b leap_stable remotes/leap/stable
  cd "$PROVIDERDIR"
  build_from_scratch
  deploy
  test

  # Checkout HEAD of current branch and re-deploy
  cd "$PLATFORMDIR"
  git checkout "$CI_COMMIT_REF"
  cd "$PROVIDERDIR"
  deploy
  test

  cleanup

}

cleanup() {
  # if everything succeeds, destroy the vm
  LEAP_CMD vm rm "${TAG}"
  [ -f "nodes/${NAME}.json" ] && /bin/rm "nodes/${NAME}.json"
}

#
# Main
#

/bin/echo "CI directory: ${ROOTDIR}"
/bin/echo "Platform directory: ${PLATFORMDIR}"

# Ensure we don't output secret stuff to console even when running in verbose mode with -x
set +x

# Configure ssh keypair
[ -d ~/.ssh ] || /bin/mkdir ~/.ssh
/bin/echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_rsa
/bin/chmod 600 ~/.ssh/id_rsa
/bin/cp "${ROOTDIR}/provider/users/gitlab-runner/gitlab-runner_ssh.pub" ~/.ssh/id_rsa.pub

# Enable xtrace again only if it was set at beginning of script
[[ $xtrace == true ]] && set -x

case "$CI_JOB_NAME" in
  ci.leap.se)
    TAG='latest'
    run ibex ssh://gitolite@leap.se/ibex
    ;;
  mail.bitmask.net)
    TAG='demomail'
    run bitmask ssh://gitolite@leap.se/bitmask
    ;;
  demo.bitmask.net)
    TAG='demovpn'
    run bitmask ssh://gitolite@leap.se/bitmask
    ;;
  deploy_test*)
    build_from_scratch
    deploy
    test
    cleanup
    ;;
  upgrade_test)
    upgrade_test
    ;;
  *)
    fail "Don't know what to do for \$CI_JOB_NAME \"$CI_JOB_NAME\"!"
    ;;
esac
