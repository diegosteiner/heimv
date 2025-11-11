#!/usr/bin/env ash
set -euo pipefail

DB_NAME="heimv_development"
FILE="$1"

psql -h db -U postgres <<SQL
  DROP DATABASE IF EXISTS "$DB_NAME";
  CREATE DATABASE "$DB_NAME";
  \c "$DB_NAME"
  CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
SQL

if [[ -f "$FILE" ]]; then
  pg_restore -U postgres --dbname "$DB_NAME" --host=db --no-privileges --no-owner --no-acl --clean --verbose $FILE
fi
