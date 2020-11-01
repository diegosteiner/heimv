#!/bin/sh
set -e

[ ! -e /app/tmp/pids/server.pid ] || rm /app/tmp/pids/server.pid

bundle check || bundle install || ash
yarn check || yarn install || ash

echo "Preparing Database"
bin/rails db:prepare RAILS_ENV=$RAILS_ENV
bin/rails db:migrate

echo "$@"
exec "$@"
