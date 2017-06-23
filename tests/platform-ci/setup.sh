#!/bin/sh

which bundle || /usr/bin/apt install bundle
bundle install --binstubs --path=vendor --with=test --jobs "$(nproc)"
bundle exec leap -v2 --yes help
