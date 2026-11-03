#!/usr/bin/env bash
# ==============================================================================
# Go-Volts Admin Web Portal - Firebase Hosting Build & Deploy
# Target Site: go-volt-9c38b (https://go-volt-9c38b.web.app)
# ==============================================================================

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ADMIN_DIR="${ROOT_DIR}/apps/admin_web"
FLUTTER_BIN="${FLUTTER_BIN:-flutter}"

# Locate flutter if not in standard PATH
if ! command -v flutter &>/dev/null; then
  if [[ -x "${HOME}/dev/flutter/bin/flutter" ]]; then
    FLUTTER_BIN="${HOME}/dev/flutter/bin/flutter"
  fi
fi

echo "=================================================="
echo "⚡ Go-Volts Admin Web — Firebase Hosting Deployment"
echo "Target Project & Site: go-volt-9c38b"
echo "Public URL: https://go-volt-9c38b.web.app"
echo "=================================================="

# 1. Build Flutter Web Release
echo "📦 Step 1: Compiling Flutter Web release artifacts..."
cd "${ADMIN_DIR}"
"${FLUTTER_BIN}" build web --release --base-href "/" "$@"

# 2. Deploy to Firebase Hosting
echo "🚀 Step 2: Deploying to Firebase Hosting..."
cd "${ROOT_DIR}"
firebase deploy --only hosting:go-volt-9c38b

echo "=================================================="
echo "✔ Deployment complete!"
echo "🔗 Access your admin portal at:"
echo "   • https://go-volt-9c38b.web.app"
echo "   • https://go-volt-9c38b.firebaseapp.com"
echo "=================================================="

