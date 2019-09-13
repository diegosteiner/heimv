#!/bin/sh
set -e

[ ! -e /app/tmp/pids/server.pid ] || rm /app/tmp/pids/server.pid

if [ "$RAILS_ENV" == "development" ]; then
  bundle check || bundle install
  yarn check --silent || yarn install
fi

if [ "$RAILS_ENV" == "test" ]; then
  bundle check || bundle install
  rails db:setup RAILS_ENV=$RAILS_ENV
fi

if [ "$WEBPACKER_PRECOMPILE" == "true" ]; then
  yarn check --silent || yarn install
  bundle exec rails webpacker:compile
fi 

[ "$MIGRATE_DATABASE" == "true" ] && bundle exec rails db:create db:migrate

exec "$@"
