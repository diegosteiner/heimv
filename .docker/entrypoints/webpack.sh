#!/bin/sh
set -e

bundle check || bundle install
yarn check --silent || yarn install

bundle exec rails webpacker:compile

exec "$@"
