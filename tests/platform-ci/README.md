# Continuous integration tests for the leap_platform code

# Setup

    cd tests/platform-ci
    ./setup.sh

# Run syntax checks and test if catalog compiles
    
    bin/rake test:syntax
    bin/rake catalog

For a list of all tasks:

    bin/rake -T

# Full integration test

You can create a virtual provider using AWS, run tests on it, then tear it down
when the tests succeed.
In order to do so, you need to set your AWS credentials as environment variables:

    export AWS_ACCESS_KEY='...'
    export AWS_SECRET_KEY='...'

If you want to login to this machine during or after the deploy you need to 

    export SSH_PRIVATE_KEY=$(cat ~/.ssh/id_rsa)

then start the deply test with

    ./ci-build.sh

# Running tests with docker and gitlab-runner

Another possibility to run the platform tests is to use [gitlab-runner](https://docs.gitlab.com/runner/)
together with [Docker](https://www.docker.com/).

Export `AWS_ACCESS_KEY`, `AWS_SECRET_KEY` and `SSH_PRIVATE_KEY` as shown above.
From the root dir of this repo run:

    gitlab-runner exec docker --env AWS_ACCESS_KEY="$AWS_ACCESS_KEY" --env AWS_SECRET_KEY="$AWS_SECRET_KEY" --env platform_PROVIDER_SSH_PRIVATE_KEY="$SSH_PRIVATE_KEY" deploy_test

See `.gitlab-ci.yml` for all the different test jobs.

To ssh into the VM you first need to enter the docker container:

    docker exec -u cirunner -it $(docker ps --latest -q) bash

From there you can access the test provider config directory and ssh into the VM:

      cd /builds/project-0/tests/platform-ci/provider/
      leap ssh citest0 
