#!/usr/bin/env bash
# ==============================================================================
# Go-Volts Admin Web Portal - Microsoft Edge Launcher
# ==============================================================================
# Launches apps/admin_web targeted directly at Microsoft Edge on macOS, Linux,
# or Windows.
# ==============================================================================

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ADMIN_DIR="${ROOT_DIR}/apps/admin_web"

PORT="${PORT:-3000}"
HOST="${HOST:-localhost}"
FLUTTER_BIN="${FLUTTER_BIN:-flutter}"

# Check if flutter is available in PATH, fallback to default dev path if exists
if ! command -v flutter &>/dev/null; then
  if [[ -x "${HOME}/dev/flutter/bin/flutter" ]]; then
    FLUTTER_BIN="${HOME}/dev/flutter/bin/flutter"
  fi
fi

OS="$(uname -s 2>/dev/null || echo "Unknown")"

echo "⚡ [Go-Volts] Preparing to launch Admin Web Console on Microsoft Edge..."

# Identify OS and Edge binary
if [[ "${OS}" == "Darwin" ]]; then
  EDGE_MACOS_PATH="/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge"
  if [[ -f "${EDGE_MACOS_PATH}" ]]; then
    echo "✔ Found Microsoft Edge on macOS: ${EDGE_MACOS_PATH}"
    export CHROME_EXECUTABLE="${EDGE_MACOS_PATH}"
    DEVICE="chrome"
  else
    echo "⚠️  Microsoft Edge not found at standard path (/Applications/Microsoft Edge.app)."
    echo "   Falling back to web-server mode on http://${HOST}:${PORT}..."
    DEVICE="web-server"
  fi
elif [[ "${OS}" == "MINGW"* || "${OS}" == "CYGWIN"* || "${OS}" == "MSYS"* ]]; then
  echo "✔ Windows detected. Targeting native Edge device driver."
  DEVICE="edge"
else
  # Linux check for microsoft-edge or microsoft-edge-stable
  if command -v microsoft-edge &>/dev/null; then
    export CHROME_EXECUTABLE="$(command -v microsoft-edge)"
    DEVICE="chrome"
  elif command -v microsoft-edge-stable &>/dev/null; then
    export CHROME_EXECUTABLE="$(command -v microsoft-edge-stable)"
    DEVICE="chrome"
  else
    echo "⚠️  Edge not detected in PATH. Defaulting to web-server mode."
    DEVICE="web-server"
  fi
fi

cd "${ADMIN_DIR}"

echo "🚀 Starting Go-Volts Admin Console on http://${HOST}:${PORT} (Device: ${DEVICE})..."

if [[ "${DEVICE}" == "web-server" ]]; then
  if [[ "${OS}" == "Darwin" ]]; then
    (sleep 3 && open -a "Microsoft Edge" "http://${HOST}:${PORT}" 2>/dev/null || true) &
  fi
  exec "${FLUTTER_BIN}" run -d web-server --web-port="${PORT}" --web-hostname="${HOST}"
else
  exec "${FLUTTER_BIN}" run -d "${DEVICE}" --web-port="${PORT}" --web-hostname="${HOST}"
fi

