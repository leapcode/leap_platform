#!/bin/sh

which bundle || /usr/bin/apt install bundle
/usr/local/bin/bundle install --binstubs --path=vendor --with=test --jobs "$(nproc)"
/usr/local/bin/bundle exec leap -v2 --yes help
