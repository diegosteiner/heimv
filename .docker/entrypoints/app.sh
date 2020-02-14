#!/bin/sh
set -e

[ ! -e /app/tmp/pids/server.pid ] || rm /app/tmp/pids/server.pid

bundle check || bundle install

echo "Preparing Database"
bin/rails db:prepare RAILS_ENV=$RAILS_ENV
bin/rails db:migrate

case "$RAILS_ENV" in
  test)
      yarn install
      bin/webpack
      ;;

  development)
      ;;
esac

echo "$@"
exec "$@"
