#!/usr/bin/env bash
# ==============================================================================
# Go_Volt Full-Stack Orchestration Launcher
# Boots backend, database, cache, and web portals via Docker Compose
# ==============================================================================

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

ACTION="${1:-up}"

case "${ACTION}" in
  up)
    echo "⚡ [Go_Volt] Starting full-stack development containers..."
    docker compose up -d
    echo ""
    echo "✔ Services online:"
    echo "  • Backend REST API:     http://localhost:8080"
    echo "  • Admin Web Portal:     http://localhost:3000"
    echo "  • Merchant Portal:      http://localhost:3001"
    echo "  • PostgreSQL Database:  localhost:5432"
    echo "  • Redis Cache:          localhost:6379"
    ;;
  down)
    echo "🛑 [Go_Volt] Stopping full-stack containers..."
    docker compose down
    ;;
  logs)
    docker compose logs -f
    ;;
  status)
    docker compose ps
    ;;
  *)
    echo "Usage: $0 {up|down|logs|status}"
    exit 1
    ;;
esac
