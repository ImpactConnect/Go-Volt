#!/usr/bin/env bash
# ==============================================================================
# Go_Volt Code Generation Runner
# Executes build_runner for JSON serialization, freezed, and riverpod models
# ==============================================================================

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

echo "⚡ [Go_Volt] Running build_runner code generation..."

# Run code generation on packages with build_runner
PACKAGES=("packages/app_models" "backend")

for pkg in "${PACKAGES[@]}"; do
  if [[ -f "${pkg}/pubspec.yaml" ]] && grep -q "build_runner" "${pkg}/pubspec.yaml"; then
    echo "▶ Generating code in ${pkg}..."
    (cd "${pkg}" && dart run build_runner build --delete-conflicting-outputs)
  fi
done

echo "🎉 [Go_Volt] Code generation complete!"
