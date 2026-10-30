#!/usr/bin/env bash
# ==============================================================================
# Go_Volt Database Migration Runner
# Executes Supabase / PostgreSQL schema migrations in chronological order
# ==============================================================================

set -euo pipefail

DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-govolts_db}"
DB_USER="${DB_USER:-govolts_user}"
DB_PASSWORD="${DB_PASSWORD:-govolts_secret_password}"

MIGRATIONS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../supabase/migrations" && pwd)"

echo "⚡ [Go_Volt] Connecting to PostgreSQL at ${DB_HOST}:${DB_PORT}/${DB_NAME} as ${DB_USER}..."

export PGPASSWORD="${DB_PASSWORD}"

# Wait for PostgreSQL to be ready
until pg_isready -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d "${DB_NAME}" >/dev/null 2>&1; do
  echo "⏳ Waiting for PostgreSQL to accept connections..."
  sleep 2
done

echo "✔ PostgreSQL is ready."

# Create schema migrations tracking table if not exists
psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d "${DB_NAME}" -v ON_ERROR_STOP=1 <<-EOSQL
  CREATE TABLE IF NOT EXISTS _schema_migrations (
    version VARCHAR(255) PRIMARY KEY,
    applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );
EOSQL

# Execute migration files in alphabetical order
for migration_file in $(ls "${MIGRATIONS_DIR}"/*.sql | sort); do
  filename=$(basename "${migration_file}")
  version="${filename%%_*}"

  # Check if migration was already applied
  is_applied=$(psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d "${DB_NAME}" -tAc \
    "SELECT 1 FROM _schema_migrations WHERE version = '${version}';")

  if [[ "${is_applied}" == "1" ]]; then
    echo "⏩ Migration ${filename} already applied. Skipping."
  else
    echo "▶ Applying migration: ${filename}..."
    psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d "${DB_NAME}" -v ON_ERROR_STOP=1 -f "${migration_file}"
    psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d "${DB_NAME}" -v ON_ERROR_STOP=1 \
      -c "INSERT INTO _schema_migrations (version) VALUES ('${version}');"
    echo "✔ Successfully applied ${filename}."
  fi
done

echo "🎉 [Go_Volt] All database migrations successfully applied!"
