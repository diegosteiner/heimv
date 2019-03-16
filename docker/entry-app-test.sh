#!/bin/sh
set -e

[ ! -e /app/tmp/pids/server.pid ] || rm /app/tmp/pids/server.pid
bundle check || bundle install
yarn check --silent || yarn install --silent
rails db:setup RAILS_ENV=$RAILS_ENV

exec "$@"
