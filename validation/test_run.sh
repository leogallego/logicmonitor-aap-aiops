#!/usr/bin/env bash
# Validation: Run stage — unknown alert triggers catch-all escalation to Edwin AI
#
# Usage:
#   Event Stream (production):  EDA_WEBHOOK_URL=https://<eda>/api/eda/v1/external_event_stream/<uuid>/post/  EDA_HMAC_SECRET=<secret>  bash validation/test_run.sh
#   Direct webhook (dev):       EDA_WEBHOOK_URL=http://localhost:5000/logicmonitor  bash validation/test_run.sh
#
# Prerequisites: EDA rulebook activation running, AAP job template "Escalate to Edwin AI" exists

set -euo pipefail

EDA_URL="${EDA_WEBHOOK_URL:-http://localhost:5000/logicmonitor}"
EDA_HMAC_SECRET="${EDA_HMAC_SECRET:-}"

PAYLOAD='{
  "type": "network_anomaly_unknown",
  "severity": "critical",
  "host": "router1",
  "id": "TEST-RUN-001",
  "message": "Unusual degradation pattern detected across multiple interfaces"
}'

echo "=== Run Stage Validation ==="
echo "Sending unknown alert type to EDA..."
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
echo "Check AAP Controller for 'Escalate to Edwin AI' job execution."
echo "Expected: Job launches, sends context to Edwin AI for MCP-based investigation."
