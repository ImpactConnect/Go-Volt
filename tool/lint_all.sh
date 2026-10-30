#!/usr/bin/env bash
# ==============================================================================
# Go_Volt Static Analysis & Lint Runner
# Runs dart analyze across all 10 packages in the monorepo workspace
# ==============================================================================

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

echo "⚡ [Go_Volt] Running static analysis across all 10 monorepo packages..."

dart run melos run lint

echo "🎉 [Go_Volt] All packages passed analysis with zero issues!"
