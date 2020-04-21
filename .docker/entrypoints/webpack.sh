#!/bin/sh
set -e

yarn install

exec "$@"
