#!/usr/bin/env bash
# Validation: Crawl stage — BGP peer down alert triggers reset
# Prerequisites: EDA webhook listening on port 5000, AAP job template "Reset BGP Session" exists

set -euo pipefail

EDA_URL="${EDA_WEBHOOK_URL:-http://localhost:5000/logicmonitor}"

echo "=== Crawl Stage Validation ==="
echo "Sending BGP peer down alert to EDA webhook..."

curl -s -w "\nHTTP Status: %{http_code}\n" \
  -X POST "$EDA_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "bgp_peer_down",
    "severity": "critical",
    "host": "router2",
    "id": "TEST-CRAWL-001",
    "message": "BGP neighbor 10.1.12.1 state changed to Idle"
  }'

echo ""
echo "Check AAP Controller for 'Reset BGP Session' job execution."
echo "Expected: Job launched targeting router2."
