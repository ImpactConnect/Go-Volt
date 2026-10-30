#!/usr/bin/env bash
# ==============================================================================
# Go_Volt Full Test Suite Runner
# Executes test suites across backend, shared packages, and client applications
# ==============================================================================

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

echo "═══════════════════════════════════════════════════════════════════════════"
echo "  ⚡ GO_VOLT MONOREPO COMPREHENSIVE TEST SUITE EXECUTION"
echo "═══════════════════════════════════════════════════════════════════════════"

START_TIME=$(date +%s)

# 1. Backend REST API and E2E Integration Tests
echo ""
echo "▶ [1/6] Running Backend Tests (Contracts, State Machines & E2E Simulation)..."
(cd backend && flutter test)
echo "✔ Backend tests passed."

# 2. Design System Tokens & Components
echo ""
echo "▶ [2/6] Running Design System Foundation Tests..."
(cd packages/design_system && flutter test)
echo "✔ Design system tests passed."

# 3. Domain Models Serialization & Enums
echo ""
echo "▶ [3/6] Running App Models Domain Tests..."
(cd packages/app_models && flutter test)
echo "✔ App models tests passed."

# 4. Merchant Web Portal & Partner API
echo ""
echo "▶ [4/6] Running Merchant Web Portal Test Suite (25 Tests)..."
(cd apps/merchant_portal && flutter test)
echo "✔ Merchant portal tests passed."

# 5. Customer Mobile Application
echo ""
echo "▶ [5/6] Running Customer App Test Suite..."
(cd apps/customer_app && flutter test)
echo "✔ Customer app tests passed."

# 6. Rider Mobile Application
echo ""
echo "▶ [6/6] Running Rider App Test Suite..."
(cd apps/rider_app && flutter test)
echo "✔ Rider app tests passed."

END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))

echo ""
echo "═══════════════════════════════════════════════════════════════════════════"
echo "  🎉 ALL TEST SUITES PASSED CLEANLY IN ${ELAPSED}s (100% SUCCESS RATE)"
echo "═══════════════════════════════════════════════════════════════════════════"
