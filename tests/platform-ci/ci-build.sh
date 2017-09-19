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

# deb repo component to configure
COMPONENT=${COMPONENT:-"master"}

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
  # allow passing into the function the services, use a default set if empty
  SERVICES=$1
  if [ -z "$SERVICES" ]
  then
      SERVICES='couchdb,soledad,mx,webapp,tor_relay,monitor'
  fi

  # when using gitlab-runner locally, CI_JOB_ID is always 1 which
  # will conflict with running/terminating AWS instances in subsequent runs
  # therefore we pick a random number in this case
  [ "${CI_JOB_ID}" == "1" ] && CI_JOB_ID="000${RANDOM}"

  # create node(s) with unique id so we can run tests in parallel
  NAME="citest${CI_JOB_ID:-0}"
  TAG='single'

  # leap_platform/tests/platform-ci/provider
  PROVIDERDIR="${ROOTDIR}/provider"
  /bin/echo "Provider directory: ${PROVIDERDIR}"
  cd "$PROVIDERDIR"

  # Create cloud.json needed for `leap vm` commands using AWS credentials
  which jq || ( apt-get update -y && apt-get install jq -y )

  # Disable xtrace
  set +x

  [ -z "$AWS_ACCESS_KEY" ]  && fail "\$AWS_ACCESS_KEY  is not set - please provide it as env variable."
  [ -z "$AWS_SECRET_KEY" ]  && fail "\$AWS_SECRET_KEY  is not set - please provide it as env variable."
  [ -z "$SSH_PRIVATE_KEY" ] && fail "\$SSH_PRIVATE_KEY is not set - please provide it as env variable."

  /usr/bin/jq ".platform_ci.auth |= .+ {\"aws_access_key_id\":\"$AWS_ACCESS_KEY\", \"aws_secret_access_key\":\"$AWS_SECRET_KEY\"}" < cloud.json.template > cloud.json
  # Enable xtrace again only if it was set at beginning of script
  [[ $xtrace == true ]] && set -x

  [ -d "./tags" ] || mkdir "./tags"
  /bin/echo "{\"environment\": \"$TAG\"}" | /usr/bin/json_pp > "${PROVIDERDIR}/tags/${TAG}.json"

  # configure deb repo component
  echo '{}' | jq ".sources.platform.apt |= { \"source\": \"http://deb.leap.se/platform\", \"component\": \"${COMPONENT}\" }" > common.json

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
  provider_name=$1
  provider_URI=$2
  platform_branch=$3

  # Setup the provider repository
  echo "Setting up the provider repository: $provider_name by cloning $provider_URI"
  git clone -q --depth 1 "$provider_URI"
  cd "$provider_name"
  echo -n "$provider_name repo at revision: "
  git rev-parse HEAD
  echo -n "Operating in the $provider_name directory: "
  pwd


  # If the third argument is set make sure we are on that platform branch
  if [[ -n $platform_branch ]]
  then
      echo "Checking out $platform_branch branch of platform"
      cd "$PLATFORMDIR"
      git checkout -B "$platform_branch"
  fi

  cd "${ROOTDIR}/${provider_name}"
  echo "Listing current node information..."
  LEAP_CMD list

  # Do the deployment
  echo "Attempting a deploy..."
  LEAP_CMD cert renew "$CI_JOB_NAME"
  deploy
  echo "Attempting to run tests..."
  test
}

upgrade_test() {
  # Checkout stable branch containing last release
  # and deploy this
  cd "$PLATFORMDIR"
  # due to cache, this remote is sometimes already added
  git remote add leap https://leap.se/git/leap_platform || true
  git fetch leap
  echo "Checking out leap/stable"
  git checkout -b leap_stable remotes/leap/stable || true
  echo -n "Current version: "
  git rev-parse HEAD
  # After checking out a different platform branch
  # bundle install is needed again
  cd "$ROOTDIR"
  /usr/local/bin/bundle install

  cd "$PROVIDERDIR"

  build_from_scratch 'couchdb,soledad,mx,webapp,tor,monitor'
  deploy
  test

  # Checkout HEAD of current branch and re-deploy
  cd "$PLATFORMDIR"
  echo "Checking out: $CI_COMMIT_SHA"
  git checkout "$CI_COMMIT_SHA"
  echo -n "Current version: "
  git rev-parse HEAD
  # After checking out a different platform branch
  # bundle install is needed again
  cd "$ROOTDIR"
  /usr/local/bin/bundle install

  cd "$PROVIDERDIR"

  # due to the 'tor' service no longer being valid in 0.10, we need to change
  # that service to 'tor_relay'. This is done by changing the services array
  # with jq to be set to the full correct list of services
  jq '.services = ["couchdb","soledad","mx","webapp","tor_relay","monitor"]' < nodes/${NAME}.json
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
    run bitmask ssh://gitolite@leap.se/bitmask master
    ;;
  demo.bitmask.net)
    TAG='demovpn'
    run bitmask ssh://gitolite@leap.se/bitmask master
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
