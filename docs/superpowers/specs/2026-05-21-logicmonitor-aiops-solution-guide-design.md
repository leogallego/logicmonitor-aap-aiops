# LogicMonitor + AAP AIOps Solution Guide — Design Spec

## Overview

A solution guide and demo showing how LogicMonitor, Edwin AI, and Red Hat Ansible Automation Platform work together to deliver closed-loop AIOps for network infrastructure. The guide follows a **crawl-walk-run maturity progression**, where each stage adds a new integration surface and a new level of intelligence.

The core narrative: **LogicMonitor and Edwin AI provide the intelligence. AAP provides the trust layer — deterministic execution, enterprise governance, and the guardrails that make AI recommendations safe for production.**

### Audiences

- Customers and prospects (primary)
- Sales engineers and solution architects
- Technical practitioners (sysadmins, network ops, DevOps)
- Red Hat and LogicMonitor partner teams

### Deliverables

| Deliverable | Description |
|-------------|-------------|
| Solution guide | `README-AIOps-LogicMonitor.md` — full markdown guide following the ansible-tmm solution guide template |
| EDA rulebook | Tiered rulebook with crawl/walk/run rules |
| Remediation playbooks | BGP reset, interface bounce, config rollback, Edwin AI escalation |
| Incident simulation playbooks | Playbooks that create different BGP failure scenarios for demo purposes |
| Workflow templates | BGP Smart Remediation (Walk), Edwin AI Escalation (Run) |
| Architecture diagrams | Per-stage flow diagrams + overall architecture |
| Validation scripts | curl commands and test scenarios for each stage |

---

## Background

### The AIOps Gap

Organizations invest heavily in observability platforms like LogicMonitor to gain visibility across their infrastructure. Yet most struggle to translate those insights into action at scale. Without automation, monitoring delivers visibility without velocity — acting manually doesn't scale, and acting without governance introduces unacceptable risk.

### LogicMonitor & Edwin AI — The Intelligence Layer

LogicMonitor is a hosted full-stack infrastructure monitoring platform with particular strength in network monitoring. Edwin AI is LogicMonitor's AI-powered ITOps layer that proactively detects, diagnoses, and remediates incidents — reducing alert noise and time to resolution through AI/ML analysis, root cause correlation, and intelligent recommendations.

### Ansible Automation Platform — The Trust Layer

AAP provides governed execution: RBAC, approval workflows, Policy as Code, audit trails, and deterministic automation. Together with LogicMonitor, they deliver the complete AIOps loop that customers cannot achieve with either platform alone.

---

## Architecture

### Integration Surfaces

Four integration surfaces are used across the three maturity stages:

| Surface | Component | Role |
|---------|-----------|------|
| **EDA webhook** | `ansible.eda.webhook` source plugin | Receives LM alert webhooks into EDA Event Streams |
| **LM device management** | `logicmonitor.integration` collection (10 modules) | Manages LM objects, reports back to LM |
| **Edwin AI query** | `logicmonitor.edwin_ai.query_api` module | Queries Edwin AI for correlated alerts, events, insights |
| **AAP MCP Server** | `ansible/aap-mcp-server` (official) | Enables Edwin AI to discover and invoke AAP automation as an AI agent |

Optional: Community LM MCP Server (`monitoringartist/logicmonitor-mcp-server`) for bidirectional LM exploration from AI agents.

Additionally, a custom MCP-based collection (`leogallego.logicmonitor_mcp`) exists in `collections/` with 73 read-only modules generated from the community MCP server. It depends on `ansible.mcp` and delegates to `ansible.mcp.run_tool` at runtime — this is the MCP Client in Playbooks pattern (AAP 2.6 capability #3). It provides typed module wrappers for alerts, resources, dashboards, collectors, topology, and more. Can be used alongside or instead of `logicmonitor.integration` for read operations during remediation and reporting.

### AIOps Value Chain Mapping

```
    LogicMonitor / Edwin AI                    AAP
  ┌─────────────────────────────┐  ┌─────────────────────────────┐
  │ DETECT → ANALYZE → RECOMMEND│→ │ GOVERN → EXECUTE → REPORT   │
  │                             │  │                             │
  │ LM monitors network devices │  │ RBAC, Policy as Code        │
  │ Edwin AI correlates alerts  │  │ Pre-tested job templates    │
  │ Edwin AI recommends actions │  │ Workflow orchestration      │
  │                             │  │ Audit trails                │
  └─────────────────────────────┘  └─────────────────────────────┘
```

### Overall Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                        LOGICMONITOR                                 │
│  ┌──────────┐    ┌──────────┐    ┌──────────────────────────────┐  │
│  │ Detection │───→│ Analysis │───→│ Edwin AI (Recommendations)  │  │
│  │ Engine    │    │ (AI/ML)  │    │                              │  │
│  └──────────┘    └──────────┘    └──────┬───────────────┬───────┘  │
│                                         │               │          │
└─────────────────────────────────────────┼───────────────┼──────────┘
                                          │               │
                        Webhook (alerts)  │               │ MCP (agentic)
                                          │               │
┌─────────────────────────────────────────┼───────────────┼──────────┐
│                  ANSIBLE AUTOMATION PLATFORM                        │
│                                         │               │          │
│  ┌──────────────────┐    ┌──────────────▼──┐   ┌───────▼────────┐ │
│  │ EDA Controller   │    │ Automation      │   │ AAP MCP Server │ │
│  │                  │    │ Controller      │   │                │ │
│  │ Event Streams    │───→│ Job Templates   │←──│ Tool discovery │ │
│  │ Rulebook         │    │ Workflows       │   │ RBAC enforced  │ │
│  │ Activations      │    │ RBAC / PaC      │   │ Human approval │ │
│  └──────────────────┘    │ Audit Logging   │   └────────────────┘ │
│                          └────────┬────────┘                      │
│                                   │                               │
│                    ┌──────────────▼──────────────┐                │
│                    │ Content Collections          │                │
│                    │ logicmonitor.integration     │                │
│                    │ logicmonitor.edwin_ai        │                │
│                    │ arista.eos                   │                │
│                    └──────────────┬──────────────┘                │
│                                   │                               │
└───────────────────────────────────┼───────────────────────────────┘
                                    │
                    ┌───────────────▼───────────────┐
                    │    TARGET INFRASTRUCTURE       │
                    │  ContainerLab + Arista cEOS    │
                    │  BGP mesh (3+ routers)         │
                    └───────────────────────────────┘
```

---

## Maturity Stages

### Stage 1 — Crawl: Event-Driven Network Remediation

**Integration surface:** EDA webhook
**Story:** Known alert, known fix. Deterministic, no AI involved.

#### Flow

```
LM detects BGP peer down on Arista router
  → LM sends webhook (HTTP POST) to EDA Event Stream
    → Rulebook activation evaluates alert
      → Condition matches: alert_type == "bgp_peer_down"
        → Triggers Job Template: "Reset BGP Session"
          → Playbook resets BGP neighbor on affected device
            → Validates BGP re-establishes
              → Reports back to LM (acknowledge/annotate alert)
```

#### Use Case: BGP Peer Down — Reset Session

**Scenario:** A BGP neighbor relationship drops to IDLE state on one router, causing a network segment to become unreachable.

**Trigger:** LogicMonitor detects BGP neighbor state change, fires a critical alert.

**Remediation playbook:** Uses `arista.eos` modules to clear/reset the BGP neighbor session on the affected device, then validates the peer re-establishes.

**Report back:** Final task uses `logicmonitor.integration` module or LM API to acknowledge the alert and add an annotation documenting the automated remediation.

**Incident simulation:** A playbook shuts down an interface on a cEOS router in ContainerLab, breaking BGP peering. This can be triggered manually or scheduled to create a demo scenario.

#### Rulebook (Crawl rules)

```yaml
---
- name: LogicMonitor Network Remediation
  hosts: all
  sources:
    - ansible.eda.webhook:
        host: 0.0.0.0
        port: 5000
  rules:
    - name: BGP peer down - known fix
      condition: event.payload.type == "bgp_peer_down"
      action:
        run_job_template:
          name: "Reset BGP Session"
          organization: "Network Ops"
          job_args:
            extra_vars:
              affected_host: "{{ event.payload.host }}"
              alert_id: "{{ event.payload.id }}"
```

#### Components

| Component | Details |
|-----------|---------|
| EDA source | `ansible.eda.webhook` on EDA Event Stream |
| Rulebook | Single rule matching `bgp_peer_down` |
| Job Template | "Reset BGP Session" |
| Playbook | `playbooks/reset_bgp_session.yml` (uses `arista.eos.eos_bgp_global`) |
| Simulation | `playbooks/simulate_bgp_down.yml` (shuts interface on cEOS) |
| Collections | `arista.eos`, `logicmonitor.integration` |

---

### Stage 2 — Walk: AI-Enriched Remediation

**Integration surface:** EDA webhook + Edwin AI query API
**Story:** Known alert, but the right fix depends on root cause. Edwin AI provides the context.

#### Flow

```
LM detects BGP flapping on Arista router
  → LM sends webhook to EDA Event Stream
    → Rulebook activation evaluates alert
      → Condition matches: alert_type == "bgp_flapping"
        → Triggers Workflow Template: "BGP Smart Remediation"
          → Node 1: "Enrich with Edwin AI"
          │   → query_api: get correlated alerts and insights
          │   → sets workflow artifacts (root_cause, correlated_alerts)
          │
          ├─ root_cause == "interface_errors"
          │   → Node 2a: "Bounce Interface"
          │
          ├─ root_cause == "cpu_exhaustion"
          │   → Node 2b: "Restart Routing Process"
          │
          ├─ root_cause == "config_drift"
          │   → Node 2c: "Rollback Configuration"
          │
          └─ Edwin AI unreachable (failure fallback)
              → Node 2d: "Default BGP Reset" (same as Crawl)
```

#### Use Case: BGP Flapping — Multiple Root Causes

**Scenario:** BGP sessions are flapping (repeatedly going up and down) on a router. The surface symptom is the same, but the root cause could be several things.

**Why AI enrichment matters:** Without Edwin AI, the rulebook would trigger the same fixed remediation every time. With Edwin AI, the workflow queries for correlated alerts and gets context:

| Edwin AI finds | Root cause | Workflow branch |
|----------------|------------|-----------------|
| BGP flapping + interface error counters spiking | Bad link/cable | Bounce the interface |
| BGP flapping + CPU at 98% on the device | Resource exhaustion | Restart routing process, investigate load |
| BGP flapping + config change event 5 minutes ago | Someone broke the config | Roll back to last known good config |
| Only BGP flapping, no correlated alerts | Unknown, possibly transient | Default BGP reset (Crawl fallback) |

**Enrichment playbook:** Uses `logicmonitor.edwin_ai.query_api` to query Edwin AI for:
- Recent alerts on the same device (lookback window)
- Correlated events across the network
- Edwin AI insights and root cause analysis

The playbook processes the response, determines the most likely root cause, and passes the finding as a workflow artifact via `ansible.builtin.set_stats`.

**Incident simulation:** Playbooks that create different failure scenarios sequentially:
- `simulate_interface_errors.yml` — injects interface errors alongside BGP flapping
- `simulate_config_drift.yml` — changes BGP neighbor config to cause flapping + config change event in LM

#### Rulebook (Walk rule added)

```yaml
    # Walk-level: known pattern, needs AI enrichment
    - name: BGP flapping - needs context
      condition: event.payload.type == "bgp_flapping"
      action:
        run_workflow_template:
          name: "BGP Smart Remediation"
          organization: "Network Ops"
          job_args:
            extra_vars:
              affected_host: "{{ event.payload.host }}"
              alert_id: "{{ event.payload.id }}"
              alert_context: "{{ event.payload }}"
```

#### Workflow Template: "BGP Smart Remediation"

```
┌─────────────────────┐
│ Enrich with Edwin AI │
│ (query_api)          │
└──────────┬──────────┘
           │
     ┌─────┼─────────────────┐
     │     │                 │
     ▼     ▼                 ▼
┌────────┐ ┌────────────┐ ┌──────────────┐
│ Bounce │ │ Restart    │ │ Rollback     │
│ Iface  │ │ Routing    │ │ Config       │
└────────┘ └────────────┘ └──────────────┘
                                │
                          (on failure)
                                │
                                ▼
                         ┌──────────────┐
                         │ Default BGP  │
                         │ Reset        │
                         └──────────────┘
```

#### Components

| Component | Details |
|-----------|---------|
| EDA source | `ansible.eda.webhook` (same as Crawl) |
| Rulebook | Adds `bgp_flapping` → workflow rule |
| Workflow Template | "BGP Smart Remediation" (4-5 nodes) |
| Enrichment playbook | `playbooks/enrich_with_edwin_ai.yml` (uses `logicmonitor.edwin_ai.query_api`) |
| Remediation playbooks | `playbooks/bounce_interface.yml`, `playbooks/restart_routing.yml`, `playbooks/rollback_config.yml` |
| Simulation playbooks | `playbooks/simulate_interface_errors.yml`, `playbooks/simulate_config_drift.yml` |
| Collections | `arista.eos`, `logicmonitor.integration`, `logicmonitor.edwin_ai` |

#### Alternative: Pre-EDA Enrichment (Option B)

If Edwin AI supports outbound webhooks or enriched alert forwarding, it can pre-enrich events before they reach EDA. In this model, Edwin AI analyzes the alert, appends root cause context to the payload, and sends the enriched event to EDA. The rulebook then has richer conditions to route directly to the correct job template without needing a workflow. This approach reduces latency but moves intelligence outside of AAP's governed workflow boundary. Document as an alternative for customers whose Edwin AI deployment supports this pattern.

---

### Stage 3 — Run: Agentic AIOps with MCP

**Integration surface:** EDA webhook + AAP MCP Server
**Story:** Unknown alert — no rulebook rule matches. Instead of dropping the event or paging a human, EDA escalates to Edwin AI, which investigates and acts as an intelligent agent via the AAP MCP Server.

#### Flow

```
LM sends alert that doesn't match any explicit rulebook rule
  → LM webhook to EDA Event Stream
    → Rulebook activation evaluates alert
      → No specific rule matches
        → Catch-all rule fires: "Escalate to Edwin AI"
          → Job Template passes raw alert context to Edwin AI
            → Edwin AI analyzes the alert
              → Edwin AI connects to AAP MCP Server
                → Discovers available job/workflow templates (within RBAC)
                → Queries inventory (which devices, groups)
                → Checks recent job history
                → Recommends: "Run 'X' workflow on device Y"
              → Human approves (or auto-approve for known patterns)
                → AAP MCP Server launches the workflow
                  → AAP executes remediation
                    → Results flow back to LM
```

#### Use Case: Unknown Network Degradation

**Scenario:** LogicMonitor detects an unusual pattern — a novel alert type or combination that doesn't match any existing rulebook rule. Maybe a new type of network degradation, a cascading failure across multiple devices, or an alert from a recently onboarded device type.

**Why this matters:** You can't write rules for everything. In traditional operations, unmatched alerts become pages to the on-call team. With Run-stage AIOps, Edwin AI picks up the investigation.

**What Edwin AI does via MCP:**
1. Receives the raw alert context from the escalation playbook
2. Connects to AAP MCP Server using the authenticated user's permissions
3. Discovers available job templates and workflow templates
4. Queries the inventory to understand the affected infrastructure
5. Checks recent job history (has this been tried before?)
6. Formulates a recommendation: which automation to run, on which hosts, with what parameters
7. Presents the recommendation for human approval (or auto-approves based on policy)
8. AAP MCP Server triggers the approved automation
9. Results are returned and reported back to LM

**The progression promise:** Over time, as Edwin AI successfully handles certain alert patterns via MCP, those patterns can be promoted into explicit Walk rules (with Edwin AI enrichment) or even Crawl rules (deterministic). The system gets smarter iteratively — the catch-all shrinks as the explicit rules grow.

#### Rulebook (Run rule added)

```yaml
    # Run-level: catch-all, no specific rule matched
    - name: Unmatched alert - escalate to Edwin AI
      condition: event.payload.type is defined
      action:
        run_job_template:
          name: "Escalate to Edwin AI"
          organization: "Network Ops"
          job_args:
            extra_vars:
              raw_alert: "{{ event.payload }}"
              source: "eda_catch_all"
```

#### Components

| Component | Details |
|-----------|---------|
| EDA source | `ansible.eda.webhook` (same as Crawl/Walk) |
| Rulebook | Adds catch-all escalation rule (lowest priority) |
| Job Template | "Escalate to Edwin AI" |
| Escalation playbook | `playbooks/escalate_to_edwin_ai.yml` — sends alert context to Edwin AI |
| AAP MCP Server | `ansible/aap-mcp-server` deployed alongside AAP |
| MCP Toolsets | `job_management`, `inventory_management` at minimum |
| Optional | Community LM MCP Server for bidirectional LM exploration |
| Collections | `logicmonitor.integration`, `logicmonitor.edwin_ai` |

#### Community LM MCP Server (Going Further)

The community `logicmonitor-mcp-server` (125 tools wrapping LM's REST API) can complement the Run stage by enabling AI agents or AAP playbooks to query LM directly for:
- Device details and topology
- Alert history and patterns
- Dashboard data
- Collector status

This adds bidirectional depth but is not required for the core Run flow. Document as a "Going Further" section for customers who want maximum integration surface.

---

## Complete Rulebook Structure

The final rulebook shows the crawl-walk-run progression in a single file — rules are evaluated in order, most specific first:

```yaml
---
- name: LogicMonitor AIOps - Network Remediation
  hosts: all
  sources:
    - ansible.eda.webhook:
        host: 0.0.0.0
        port: 5000
  rules:
    # --- CRAWL: Known alerts, deterministic remediation ---
    - name: BGP peer down - reset session
      condition: event.payload.type == "bgp_peer_down"
      action:
        run_job_template:
          name: "Reset BGP Session"
          organization: "Network Ops"
          job_args:
            extra_vars:
              affected_host: "{{ event.payload.host }}"
              alert_id: "{{ event.payload.id }}"

    # --- WALK: Known alerts, AI-enriched remediation ---
    - name: BGP flapping - smart remediation
      condition: event.payload.type == "bgp_flapping"
      action:
        run_workflow_template:
          name: "BGP Smart Remediation"
          organization: "Network Ops"
          job_args:
            extra_vars:
              affected_host: "{{ event.payload.host }}"
              alert_id: "{{ event.payload.id }}"
              alert_context: "{{ event.payload }}"

    # --- RUN: Unknown alerts, escalate to Edwin AI ---
    - name: Unmatched alert - escalate to Edwin AI
      condition: event.payload.type is defined
      action:
        run_job_template:
          name: "Escalate to Edwin AI"
          organization: "Network Ops"
          job_args:
            extra_vars:
              raw_alert: "{{ event.payload }}"
              source: "eda_catch_all"
```

---

## Demo Environment

**Base infrastructure:** Adapted from `zt-network-automation-workshop` (https://github.com/rhpds/zt-network-automation-workshop, https://github.com/rhpds/zt-network-automation-workshop`). The workshop provides an RHDP-ready environment with a ContainerLab VM (`ansiblebu-containerlab-v2`, 32Gi/12 cores), an AAP 2.6 Controller VM (`aap-2.6-2-ceh`, 32G/4 cores), and bootstrap automation using `ansible.controller` modules. We reuse the VM images, deploy patterns (including the `containerlab-resume` systemd service), and Controller provisioning patterns while adding our own BGP topology, EDA rulebook, LM-specific job/workflow templates, and Edwin AI integration. See `resources/reference.md` section "Network Lab Base" for full details.

| Component | Implementation | Notes |
|-----------|---------------|-------|
| Network topology | ContainerLab with 3 Arista cEOS routers | BGP eBGP mesh (our custom topology on top of workshop clab VM) |
| Monitoring | LogicMonitor instance | Live access available |
| Edwin AI | Edwin AI portal | Live access available |
| AAP | AAP 2.6 | Automation Controller + EDA Controller (workshop `aap-2.6-2-ceh` image) |
| AAP MCP Server | `ansible/aap-mcp-server` | Deployed alongside AAP |
| AAP Bootstrap | `lab-automation/aap_bootstrap_lm_aiops.yml` | Creates LM-specific Controller objects (adapted from workshop pattern) |
| Collections | `logicmonitor.integration`, `logicmonitor.edwin_ai`, `arista.eos` | Installed in EE |
| LM MCP Server | `monitoringartist/logicmonitor-mcp-server` | Optional, for Going Further section |

### Incident Simulation Playbooks

Playbooks that create specific failure scenarios for demo purposes:

| Playbook | What it does | Stage |
|----------|-------------|-------|
| `simulate_bgp_down.yml` | Shuts interface on cEOS to break BGP peering | Crawl |
| `simulate_interface_errors.yml` | Injects interface errors + BGP flapping | Walk |
| `simulate_config_drift.yml` | Changes BGP neighbor config to cause flapping + config event | Walk |
| `simulate_unknown_alert.yml` | Sends a novel alert type via LM webhook that has no matching rule | Run |

---

## Prerequisites

| Requirement | Version / Details |
|-------------|-------------------|
| Ansible Automation Platform | 2.6 (Controller + EDA Controller) |
| LogicMonitor | Active account with API access |
| Edwin AI | Portal with API credentials (`access_id`, `access_key`) |
| AAP MCP Server | Deployed, Technology Preview in AAP 2.6 |
| ContainerLab | Latest, with Arista cEOS images |
| Arista cEOS | Container image (requires Arista account to download) |
| Collections | `logicmonitor.integration`, `logicmonitor.edwin_ai`, `arista.eos`, `ansible.eda` |
| Python | >= 3.9, `requests` package |

---

## Solution Guide Structure

The markdown guide (`README-AIOps-LogicMonitor.md`) follows the ansible-tmm solution guide template:

```
1.  Overview
    - Hero image + value proposition
    - "LogicMonitor + AAP: From Alert Noise to Governed Remediation"

2.  Background
    - The AIOps gap: detection without action
    - LogicMonitor & Edwin AI: the intelligence layer
    - Ansible Automation Platform: the trust layer

3.  Solution
    - Components table
    - Personas & benefits (Network Ops, Platform Eng, Security/Compliance)
    - Demo/lab links

4.  Prerequisites
    - Platform versions, collections, credentials
    - ContainerLab + Arista cEOS setup

5.  Integration Architecture
    - Overall architecture diagram
    - AIOps value chain mapping
    - Integration surfaces table

6.  Stage 1 — Crawl: Event-Driven Network Remediation
    - Architecture diagram (LM → EDA → AAP)
    - Setup: LM webhook, EDA rulebook, job template
    - Use case: BGP peer down → reset session
    - Incident simulation
    - Validation steps

7.  Stage 2 — Walk: AI-Enriched Remediation
    - Architecture diagram (adds Edwin AI query)
    - Setup: Edwin AI credentials, workflow template
    - Use case: BGP flapping → Edwin AI enrichment → smart routing
    - Incident simulation (multiple root causes)
    - Validation steps
    - Alternative: pre-EDA enrichment (Option B)

8.  Stage 3 — Run: Agentic AIOps with MCP
    - Architecture diagram (adds AAP MCP Server)
    - Setup: AAP MCP Server deployment, toolsets
    - Use case: unknown alert → catch-all → Edwin AI investigates via MCP
    - The progression promise
    - Validation steps
    - Going Further: community LM MCP Server

9.  Validation & Troubleshooting
    - Per-stage validation checklist
    - Common issues table
    - Test curl commands

10. Maturity Path Summary
    - Crawl → Walk → Run visual progression
    - When to advance to the next stage
    - Promoting patterns: Run → Walk → Crawl

11. ROI Recap
    - MTTR reduction, alert noise reduction
    - Governance compliance, audit readiness
    - Metrics for success (MTTR, remediation success rate, on-call escalations, etc.)

12. Sources & Next Steps
    - Links to repos, docs, collections
    - Related solution guides
    - Trial/consulting CTAs
```

---

## What We're NOT Building

- No custom EDA source plugin — using `ansible.eda.webhook`
- No modifications to `logicmonitor.integration` or `logicmonitor.edwin_ai` collections
- No custom MCP server — using official AAP MCP Server
- No Kafka/Telegraf telemetry pipeline — LM replaces that stack
- No video production — parked for later brainstorming
- No Cisco devices — using Arista cEOS in ContainerLab for BGP scenarios
- No NetBox integration — the `summit-netbox-circuits-demo` (WAN circuit failover with NetBox + EDA + AAP 2.6) is a candidate for future enhancement, potentially adding LM-monitored circuit health as a failover trigger and NetBox as shared CMDB. See `resources/reference.md` section "Future Enhancement: NetBox Circuits Demo"

---

## Open Questions

1. **LM webhook payload structure:** What does LogicMonitor's actual webhook JSON look like for BGP-related alerts? Need to verify field names (`type`, `host`, `severity`, etc.) to write accurate rulebook conditions.
2. **Edwin AI `query_api` response structure:** What exactly does Edwin AI return for correlated alerts? Need to understand the response to design the enrichment playbook's branching logic.
3. **Edwin AI → AAP MCP Server integration:** How does Edwin AI connect to an MCP server operationally? Is this a built-in capability of Edwin AI, or does it require configuration?
4. **ContainerLab + LM monitoring:** Can LogicMonitor monitor Arista cEOS containers running in ContainerLab? What collector configuration is needed?
5. **Incident simulation fidelity:** Will simulated failures (interface shutdown, config changes) produce distinct enough alert patterns in Edwin AI for the Walk demo to show different branches?
