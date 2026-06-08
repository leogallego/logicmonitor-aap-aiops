#!/usr/bin/env bash
# Validation: Walk stage — BGP flapping alert triggers Edwin AI-enriched workflow
#
# Usage:
#   Event Stream (production):  EDA_WEBHOOK_URL=https://<eda>/api/eda/v1/external_event_stream/<uuid>/post/  EDA_HMAC_SECRET=<secret>  bash validation/test_walk.sh
#   Direct webhook (dev):       EDA_WEBHOOK_URL=http://localhost:5000/logicmonitor  bash validation/test_walk.sh
#
# Prerequisites: EDA rulebook activation running, AAP workflow "BGP Smart Remediation" exists

set -euo pipefail

EDA_URL="${EDA_WEBHOOK_URL:-http://localhost:5000/logicmonitor}"
EDA_HMAC_SECRET="${EDA_HMAC_SECRET:-}"

PAYLOAD='{
  "type": "bgp_flapping",
  "severity": "warning",
  "host": "router2",
  "id": "TEST-WALK-001",
  "message": "BGP neighbor 10.1.12.1 flapping - 5 state changes in 10 minutes"
}'

echo "=== Walk Stage Validation ==="
echo "Sending BGP flapping alert to EDA..."
echo "  URL: ${EDA_URL}"

HMAC_HEADER=()
if [[ -n "$EDA_HMAC_SECRET" ]]; then
  SIGNATURE=$(echo -n "$PAYLOAD" | openssl dgst -sha256 -hmac "$EDA_HMAC_SECRET" -binary | xxd -p -c 256)
  HMAC_HEADER=(-H "X-Hub-Signature-256: sha256=${SIGNATURE}")
  echo "  HMAC: enabled"
else
  echo "  HMAC: disabled (set EDA_HMAC_SECRET to enable)"
fi

curl -s -w "\nHTTP Status: %{http_code}\n" \
  -X POST "$EDA_URL" \
  -H "Content-Type: application/json" \
  "${HMAC_HEADER[@]}" \
  -d "$PAYLOAD"

echo ""
echo "Check AAP Controller for 'BGP Smart Remediation' workflow execution."
echo "Expected: Workflow launches, first node queries Edwin AI, then branches."
