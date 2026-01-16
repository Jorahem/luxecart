#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./scripts/migrate_sqlite_to_pg.sh /absolute/path/to/storage/development.sqlite3 postgresql://user:pass@localhost/dbname
#
# Example:
#   ./scripts/migrate_sqlite_to_pg.sh ./storage/development.sqlite3 postgresql://luxecart_user:luxecart_pass@localhost/luxecart_development

SQLITE_FILE=${1:-}
PG_URL=${2:-}

if [[ -z "$SQLITE_FILE" || -z "$PG_URL" ]]; then
  echo "Usage: $0 /path/to/development.sqlite3 postgresql://user:pass@host/dbname"
  exit 2
fi

if [[ ! -f "$SQLITE_FILE" ]]; then
  echo "SQLite file not found: $SQLITE_FILE"
  exit 3
fi

if ! command -v pgloader >/dev/null 2>&1; then
  echo "pgloader not installed. Please install it (apt/brew). See docs/POSTGRES_MIGRATION.md for instructions."
  exit 4
fi

echo "Backing up sqlite file..."
cp -v "$SQLITE_FILE" "${SQLITE_FILE}.bak.$(date +%Y%m%d%H%M%S)"

echo "Running pgloader from sqlite://${SQLITE_FILE} to ${PG_URL}"
pgloader "sqlite:///${SQLITE_FILE}" "${PG_URL}"

echo "pgloader finished. Please verify data in Postgres (rails console / psql)."
echo "Example verification commands:"
echo "  bundle exec rails c"
echo "  ActiveRecord::Base.connection.adapter_name"
echo "  User.count"
echo "  Product.count"