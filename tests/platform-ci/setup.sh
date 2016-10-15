#!/bin/sh

which bundle || /usr/bin/apt install bundle
/usr/local/bin/bundle install --binstubs --path=/var/cache/gitlab-runner/ --with=test --jobs "$(nproc)"
