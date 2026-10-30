#!/usr/bin/env bash
# ==============================================================================
# Go_Volt Infrastructure Healthcheck Probe
# Checks availability of Backend API, PostgreSQL, and Redis
# ==============================================================================

set -euo pipefail

API_URL="${API_URL:-http://localhost:8080/health}"
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_USER="${DB_USER:-govolts_user}"
DB_NAME="${DB_NAME:-govolts_db}"
REDIS_HOST="${REDIS_HOST:-localhost}"
REDIS_PORT="${REDIS_PORT:-6379}"

echo "🔍 Probing Go_Volt Infrastructure Health..."

# 1. Backend API
echo -n "  • Backend API (${API_URL}): "
if curl -sf "${API_URL}" >/dev/null 2>&1; then
  echo "✔ HEALTHY"
else
  echo "❌ UNREACHABLE"
fi

# 2. PostgreSQL
echo -n "  • PostgreSQL (${DB_HOST}:${DB_PORT}): "
if pg_isready -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d "${DB_NAME}" >/dev/null 2>&1; then
  echo "✔ HEALTHY"
else
  echo "❌ UNREACHABLE"
fi

# 3. Redis
echo -n "  • Redis (${REDIS_HOST}:${REDIS_PORT}): "
if nc -z "${REDIS_HOST}" "${REDIS_PORT}" >/dev/null 2>&1 || (which redis-cli >/dev/null 2>&1 && redis-cli -h "${REDIS_HOST}" -p "${REDIS_PORT}" ping >/dev/null 2>&1); then
  echo "✔ HEALTHY"
else
  echo "❌ UNREACHABLE"
fi
