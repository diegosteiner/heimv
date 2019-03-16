#!/bin/sh
set -e

yarn check --silent || yarn install --silent

exec "$@"
