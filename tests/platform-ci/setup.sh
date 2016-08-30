#!/bin/sh

which bundle || apt install bundle
bundle install --binstubs --path=vendor --with=test