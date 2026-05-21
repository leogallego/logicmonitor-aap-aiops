# CLAUDE.md

## Project Overview

LogicMonitor + Red Hat Ansible Automation Platform AIOps solution guide and demo.
Demonstrates closed-loop network remediation using a crawl-walk-run maturity model.

## Architecture

- **Crawl:** LM alert → EDA webhook → rulebook → Job Template (BGP reset)
- **Walk:** LM alert → EDA webhook → rulebook → Workflow Template (Edwin AI enrichment → branched remediation)
- **Run:** LM alert → EDA webhook → rulebook catch-all → escalate to Edwin AI → AAP MCP Server (agentic)

## Key Collections

- `arista.eos` — Arista EOS network modules
- `logicmonitor.integration` — LM device management + EDA webhook
- `logicmonitor.edwin_ai` — Edwin AI query API
- `leogallego.logicmonitor_mcp` — custom MCP-based LM collection (73 read modules)

## Network Lab

ContainerLab with 3 Arista cEOS routers in a BGP mesh topology.
Topology defined in `containerlab/bgp-topology.yml`.
Base infrastructure adapted from zt-network-automation-workshop (RHDP).

## Base Infrastructure

The `zt-network-automation-workshop` repo provides reusable patterns:
- AAP 2.6 Controller bootstrap (`ansible.controller` modules)
- ContainerLab VM setup with auto-resume systemd service
- LB port-forwarding inventory pattern for router access from AAP
- Arista connection group vars

## Conventions

- All playbooks follow Red Hat CoP automation good practices
- Fully qualified collection names always (e.g., `arista.eos.eos_bgp_global`)
- YAML native booleans (`true`/`false`)
- 2-space indentation
- Snake_case for all names
- Imperative task names ("Ensure BGP neighbor is configured")
