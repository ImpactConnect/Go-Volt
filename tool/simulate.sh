#!/usr/bin/env bash
# ==============================================================================
# Go_Volt End-to-End Multi-Surface Simulation Launcher
# ==============================================================================

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

(cd backend && dart run ../tool/simulate_e2e_lifecycle.dart)
