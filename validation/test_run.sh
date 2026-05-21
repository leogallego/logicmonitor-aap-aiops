#!/usr/bin/env bash
# Validation: Run stage — unknown alert triggers catch-all escalation to Edwin AI
# Prerequisites: EDA webhook on port 5000, AAP job template "Escalate to Edwin AI" exists

set -euo pipefail

EDA_URL="${EDA_WEBHOOK_URL:-http://localhost:5000/logicmonitor}"

echo "=== Run Stage Validation ==="
echo "Sending unknown alert type to EDA webhook..."

curl -s -w "\nHTTP Status: %{http_code}\n" \
  -X POST "$EDA_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "network_anomaly_unknown",
    "severity": "critical",
    "host": "router1",
    "id": "TEST-RUN-001",
    "message": "Unusual degradation pattern detected across multiple interfaces"
  }'

echo ""
echo "Check AAP Controller for 'Escalate to Edwin AI' job execution."
echo "Expected: Job launches, sends context to Edwin AI for MCP-based investigation."
