#!/bin/sh
set -e

[ ! -e /app/tmp/pids/server.pid ] || rm /app/tmp/pids/server.pid

if [ "$BUNDLE_INSTALL" != "" ]; then
  bundle check || bundle install
fi

if [ "$YARN_INSTALL" != "" ]; then
  yarn install
fi

case "$RAILS_ENV" in
  test)
      bundle check || bundle install
      bin/rails db:prepare RAILS_ENV=$RAILS_ENV
      ;;

  development)
      bundle check || bundle install
      yarn check --silent || yarn install
      bin/rails db:prepare RAILS_ENV=$RAILS_ENV
      ;;

  *)
      [ "$MIGRATE_DATABASE" != "" ] && bin/rails db:migrate
      bundle exec rails webpacker:compile
      ;;
esac

echo "$@"
exec "$@"
