#!/usr/bin/env bash
# Validation: Walk stage — BGP flapping alert triggers Edwin AI-enriched workflow
# Prerequisites: EDA webhook on port 5000, AAP workflow "BGP Smart Remediation" exists

set -euo pipefail

EDA_URL="${EDA_WEBHOOK_URL:-http://localhost:5000/logicmonitor}"

echo "=== Walk Stage Validation ==="
echo "Sending BGP flapping alert to EDA webhook..."

curl -s -w "\nHTTP Status: %{http_code}\n" \
  -X POST "$EDA_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "bgp_flapping",
    "severity": "warning",
    "host": "router2",
    "id": "TEST-WALK-001",
    "message": "BGP neighbor 10.1.12.1 flapping - 5 state changes in 10 minutes"
  }'

echo ""
echo "Check AAP Controller for 'BGP Smart Remediation' workflow execution."
echo "Expected: Workflow launches, first node queries Edwin AI, then branches."
