# LogicMonitor + AAP AIOps — Resource Reference

All source materials, collections, tools, and documentation used for this project.

---

## Ansible Collections

### logicmonitor.integration

The main LogicMonitor Ansible collection for managing LM infrastructure objects.

- **Source:** https://github.com/ansible-collections/logicmonitor
- **Galaxy:** `ansible-galaxy collection install logicmonitor.integration`
- **License:** Apache 2.0
- **Modules (10):**
  - `lm_info` — gather information about LM objects (collectors, devices, groups)
  - `lm_collector` — manage collectors (add, update, remove, sdt)
  - `lm_collector_group` — manage collector groups (add, update, remove)
  - `lm_otel_collector` — manage OpenTelemetry collectors (add, remove)
  - `lm_device` — manage devices (add, update, remove, sdt)
  - `lm_device_group` — manage device groups (add, update, remove, sdt)
  - `lm_alert_rule` — manage alert rules (add, update, remove)
  - `lm_escalation_chain` — manage escalation chains (add, update, remove)
  - `lm_datasource` — manage device datasources (sdt)
  - `lm_website_check` — manage website checks (sdt)
- **EDA Plugin:**
  - `logicmonitor.integration.webhook` — EDA event source that receives LM alerts/events via webhook
- **Example Playbooks:** restart_server, free_file_system, start/stop_webserver, start/stop_lm-collector, run_script
- **Requirements:** Ansible >= 2.13.0, Python >= 2.7, requests, aiohttp, asyncio, PyYAML

### logicmonitor.edwin_ai

EDA collection for LogicMonitor's Edwin AI platform.

- **Source:** https://github.com/logicmonitor/logicmonitor.edwin_ai
- **Galaxy:** https://galaxy.ansible.com/ui/repo/published/logicmonitor/edwin_ai/
- **Version:** 1.0.1 (created 2026-02-10, updated 2026-03-27)
- **License:** Apache 2.0
- **Module:**
  - `query_api` — queries Edwin AI at `{portal}.dexda.ai/ui/query/records` for alerts, events, or insights (severity >= 4, time-bounded, configurable lookback window)
    - Parameters: `access_id`, `access_key`, `portal`, `record_type` (alerts/events/insights), `fields`, `limit`, `lookback_window`
- **Doc Fragments:** `auth`, `portal`
- **Module Utils:** `_rest_methods`
- **No EDA source plugin, no roles**
- **Includes:** execution-environment.yml, sample_playbook.yml, CI workflows
- **Requirements:** Ansible >= 2.16.0, Python `requests`

---

## MCP Servers

### AAP MCP Server (Official)

Official Red Hat MCP server bridging AI agents with Ansible Automation Platform.

- **Source:** https://github.com/ansible/aap-mcp-server
- **Status:** Pre-release (no published releases, 207 commits on main)
- **License:** Apache 2.0
- **Tech:** TypeScript, Node.js 22+, Streamable HTTP transport
- **Services wrapped (4):**
  - Controller — job templates, inventories, projects, hosts, groups, credentials
  - Galaxy — collection management
  - EDA — activations, projects, rulebooks, decision environments
  - Gateway — user/team management, organizations, activity streams
- **Tools:** Dynamically generated from AAP OpenAPI specs. Key examples:
  - `controller.job_templates_launch_create` — launch job templates
  - `controller.workflow_job_templates_launch_create` — launch workflows
  - `controller.jobs_read` — read job status
  - `controller.inventories_list` — list inventories
  - `controller.hosts_list` — list hosts
  - `gateway.activitystream_list` — audit log
- **Configuration:** YAML (`aap-mcp.yaml`) + env vars + defaults
- **Endpoints:** `/mcp`, `/mcp/{toolset}`, `/metrics`, `/api/v1/health`
- **Security:** Bearer token (AAP OAuth2), read-only by default, write operations opt-in via `ALLOW_WRITE_OPERATIONS`
- **Toolsets:** Role-based access control via named toolset groups (job_management, inventory_management, etc.)

### LogicMonitor MCP Server (Community)

Community MCP server wrapping the LogicMonitor REST API.

- **Source:** https://github.com/monitoringartist/logicmonitor-mcp-server
- **Author:** Monitoring Artist (not an official LogicMonitor product)
- **License:** AGPL-3.0
- **Tech:** TypeScript, Node.js >= 18, npm package `logicmonitor-mcp-server`
- **Transport:** STDIO, SSE, Streamable HTTP
- **Tools (125 total):** 73 read-only + 52 write
  - Alert management (10): list, get, acknowledge, add notes, manage rules
  - Resource/device management (6): list, get, create, update, delete, generate links
  - Resource groups (5): list, get, create, update, delete
  - DataSources & monitoring (11): datasources, eventsources, configsources, instances, data
  - Dashboards & reporting (13): dashboards, groups, reports, report groups
  - Collectors & infrastructure (11): collectors, groups, versions, netscans, topology
  - Website monitoring (9): websites, groups, checkpoints
  - Services (10): services, service groups
  - Alert configuration (15): escalation chains, recipients, recipient groups
  - Integrations (5): list, get, create, update, delete
  - Admin & security (10): users, roles, access groups, API tokens
  - Properties (4): resource/group properties
  - SDT (4): scheduled downtime management
  - OpsNotes (5): operational notes
  - Audit (2): audit logs
- **Security:** Read-only mode by default, OAuth/OIDC support, TLS, CSRF protection, rate limiting
- **Auth:** LM Bearer Token from Settings > Users & Roles > API Tokens
- **API:** `https://{company}.logicmonitor.com/santaba/rest/...`

---

## Documentation & Guides

### Partnering with Red Hat Ansible for AIOps

Internal Red Hat partner guide for building AIOps integrations with AAP.

- **Location:** `/home/lgallego/Documents/Partnering with Red Hat for AIOps.pdf`
- **Version:** 1.0, April 15, 2026
- **Key concepts:**
  - Value chain: Detect → Analyze → Recommend → Govern → Execute → Report
  - Partner provides intelligence (detect, analyze, recommend); AAP provides trust layer (govern, execute, report)
  - Three integration patterns: EDA (event-driven), MCP Server (agentic AI), Direct API
  - Crawl-Walk-Run adoption path
  - Seven AAP 2.6 capabilities: EDA, MCP Server, MCP Client in EEs, Automation Dashboard, ALIA, Policy Enforcement, Content Collections
  - Governance boundary: pre-approved automation, not dynamically generated code
  - "If your AI makes a recommendation at 3am, what prevents a bad recommendation from reaching production?"

### Existing AIOps Solution Guides

Reference guides from other partner integrations.

- **Site:** https://ansible-tmm.github.io/solution-guides/
- **Repo:** https://github.com/ansible-tmm/solution-guides
- **Format:** Flat markdown files at repo root (README-<topic>.md), deployed via Jekyll/GitHub Pages
- **Relevant guides:**
  - **Instana** (`README-Instana-AIOps.md`) — closest reference for this project
    - Dual integration paths: Path A (EDA webhook) + Path B (Instana Automation Framework)
    - Three use cases: service latency spike, database degradation, bad deployment rollback
    - AI-assisted routing (optional): workflow queries controller for templates, sends to LLM for routing
    - Crawl/Walk/Run maturity model section
    - Structure: Overview, Background, Solution, Prerequisites, Architecture, Walkthrough (5 parts), Validation, Maturity Path, ROI, Sources
  - **Splunk** (`README-AIOps-Splunk-ITSI.md`) — three use cases: predictive anomaly, RHEL remediation, network OSPF
  - **ServiceNow** (`README-AIOps-ServiceNow.md`) — LEAP + MCP Server integration
  - **Base AIOps** (`README-AIOps.md`) — foundational concepts without specific partner
  - **AWS SQS** and **Azure Service Bus** — work in progress

### Best Practices Guide

- **File:** `README-best-practices.md` in the solution-guides repo
- **Content:** Framework, checklists, and quality scoring model for creating enterprise-grade solution guides

---

## Network Lab Base — zt-network-automation-workshop

RHDP (Red Hat Demo Platform) network automation workshop used as base infrastructure for the LM AIOps demo.

- **Source:** https://github.com/rhpds/zt-network-automation-workshop
- **Local copy:** `/home/lgallego/Claude/zt-network-automation-workshop`
- **License:** MIT
- **Platform:** RHDP (Showroom), KubeVirt VMs, AAP 2.6

### Infrastructure

Three VMs provisioned via RHDP cloud-init (`config/instances.yaml`):

| VM | Image | Resources | Purpose |
|----|-------|-----------|---------|
| **containerlab** | `ansiblebu-containerlab-v2` | 32Gi RAM, 12 cores, 200Gi disk | Hosts ContainerLab topology with virtual routers |
| **control** | `aap-2.6-2-ceh` | 32G RAM, 4 cores, 50Gi disk | AAP 2.6 Controller |
| **vscode** | `rhel-9.6` | 8G RAM, 2 cores, 40G disk | Browser-based VS Code IDE |

### Virtual Routers

| Device | Network OS | Connection | Port (via LB) | Credentials |
|--------|-----------|------------|----------------|-------------|
| rtr1 | Cisco IOS-XE (vrnetlab) | `network_cli` | 2222 | admin / admin@123 |
| rtr2 | Arista vEOS-lab | `network_cli` | 2223 | admin / admin@123 |
| rtr3 | Juniper Junos (vrnetlab) | `netconf` | 2225 (SSH), 2224 (NETCONF) | admin / admin@123 |
| rtr4 | Arista vEOS-lab | `network_cli` | 2226 | admin / admin@123 |

- Management subnet: `172.20.20.0/24` (Docker bridge on containerlab VM)
- External access: LoadBalancer service (`containerlab-fip`) maps ports 2222–2228 to router SSH
- Auto-resume on boot: systemd service `containerlab-resume` re-deploys last topology after VM pause/resume

### AAP Bootstrap Automation

The `lab-automation/playbooks/aap_bootstrap.yml` + task includes fully provision AAP Controller:
- **Organizations:** "Red Hat network organization", "Red Hat compute organization"
- **Inventory:** "Workshop Inventory" with groups (cisco, arista, juniper, network) and hosts (rtr1-4, ansible-1, backup-server)
- **Credentials:** Machine (SSH to routers), Controller (AAP API access)
- **Execution Environment:** "Network EE" from `quay.io/acme_corp/network-ee`
- **Job Templates (8):** Network-Commands, Network-Reload, Network-User, Network-Time, Network-Report, Network-System, Network-Facts, Network-Backup
- **Users (7):** network-operator, network-admin, bbelcher, tbelcher, lbelcher, libelcher, gbelcher
- **Teams:** Netops, Netadmin, Compute T1, Compute T2
- **RBAC:** network-admin gets Admin on all job templates; both operators are members of network org
- **AAP 2.6 gateway password workaround:** PATCH `/api/gateway/v1/users/` to enable login

### What We Reuse for LM AIOps

- ContainerLab VM image, deploy/resume patterns, systemd service
- AAP 2.6 Controller VM image with pre-installed platform
- AAP bootstrap automation pattern (`ansible.controller` modules) for creating our custom job templates, workflow templates, and EDA objects
- Arista group vars and LB port-forwarding inventory pattern
- SSH key exchange and router access setup scripts

### What We Need to Build on Top

- **BGP topology:** Workshop has vanilla routers with no BGP config — we create our own 3-router Arista cEOS eBGP mesh
- **EDA components:** No rulebooks, event sources, or activations exist in the workshop
- **Workflow templates:** Workshop only has simple job templates
- **LM/Edwin AI integration:** New job templates and playbooks for our maturity stages
- **Simulation playbooks:** New playbooks to create BGP incidents

### Known Issue: Arista vEOS + Nested KVM

Arista vEOS (vrnetlab) can fail on nested KVM with `failed to set MSR 0x345` errors — QEMU crashes. Workaround: use `ceos` (container EOS) instead of `veos` (VM-based). Our plan already uses `arista_ceos` kind, which avoids this entirely.

---

## Key Architecture Patterns

### Pattern 1: EDA (Event-Driven Ansible)

Best for: real-time event response, high-volume events, observability platforms.

```
LM detects issue → generates alert → webhook POST to EDA Event Stream
→ rulebook evaluates conditions → triggers AAP job template → remediation executes
→ results reported back to LM
```

- Uses `logicmonitor.integration.webhook` source plugin
- Decoupled: LM sends generic JSON, rulebook handles mapping
- Asynchronous (fire-and-forget from LM's perspective)

### Pattern 2: MCP Server (Agentic AI)

Best for: AI agent integration, interactive troubleshooting, natural language operations.

```
Edwin AI needs to act → connects to AAP MCP Server
→ discovers available job templates (within RBAC)
→ recommends action → human approves → MCP triggers AAP → results returned
```

- Uses official AAP MCP Server (`ansible/aap-mcp-server`)
- Could also use community LM MCP Server for bidirectional exploration
- Governance-first: RBAC enforced at protocol level
- Synchronous, bidirectional

### Pattern 3: Direct API

Best for: custom orchestration, programmatic access, deep integration.

```
LM calls AAP REST API directly → authenticates → launches job/workflow
→ polls for completion → retrieves results
```

- Maximum control but tight coupling (must know AAP template IDs)
- Used as fallback or for advanced customization

---

## Workshops & Labs

### EDA NetOps ChatOps Workshop (Instruqt)

Hands-on Instruqt lab for event-driven network automation with Cisco and Arista devices.

- **Source:** https://github.com/ansible-tmm/instruqt-track-backups/tree/main/aap25-eda-netops-chatops
- **Platform:** AAP 2.5, Instruqt
- **Developer:** lgallego@redhat.com
- **Lab environment:**
  - AAP 2.5 CE (control VM, n1-standard-8)
  - Cisco Cat8000v (network device)
  - 3x Arista cEOS (via podman on podman-host)
  - Kafka + Zookeeper (event bus)
  - Gitea (git server)
  - Ansible DevTools VM
- **17 challenges covering:**
  1. AAP introduction and UI exploration
  2-5. Inventory, project, credentials, job template setup
  6-7. BGP configuration (Arista `eos_bgp_global`) + validation
  8. Workflow templates
  9. EDA intro: webhook-based rulebook (CLI)
  10. EDA: Kafka-based rulebook
  11. EDA Controller introduction
  12. Telemetry pipeline: Cisco MDT → Telegraf → Kafka
  13. EDA Controller: rulebook activation + remediation job template
  14. Closed-loop demo: interface down → telemetry → Kafka → EDA → auto-remediation (`no shutdown`)
  15. ChatOps notifications: BGP IDLE → EDA → Mattermost notification (gNMI/BGP telemetry)
  16. Full ChatOps loop: chat notification + human types `remediate-bgp` → outgoing webhook → EDA → BGP workflow
  17. Surveys
- **Key patterns reusable for LM solution guide:**
  - Telemetry pipeline architecture (Cisco MDT → Telegraf → Kafka → EDA)
  - BGP remediation playbooks (`arista.eos.eos_bgp_global`, `cisco.ios.ios_interfaces`)
  - EDA rulebook structure for network events
  - ChatOps human-in-the-loop pattern (notification + chat-triggered remediation)
  - Closed-loop remediation validation
- **Differences from our LM solution guide:**
  - Uses Kafka/Telegraf telemetry, not LM webhooks
  - No AI/Edwin AI enrichment
  - No MCP server integration
  - AAP 2.5 (our guide targets AAP 2.6)
  - Flat learning path, no crawl-walk-run progression

---

## Future Enhancement: NetBox Circuits Demo

Summit demo showing WAN circuit failover with NetBox as source of truth + EDA + AAP 2.6. Candidate for future integration with the LM AIOps solution guide.

- **Local copy:** `/home/lgallego/Claude/summit-netbox-circuits-demo`
- **Source:** https://github.com/leogallego/summit-netbox-circuits-demo
- **Author:** lgallego
- **License:** (internal demo)

### What It Does

A global enterprise operates WAN circuits across three sites (GB-Bristol, US-Atlanta, AR-Buenos-Aires). When a primary circuit fails, the entire failover sequence runs automatically in under 30 seconds:

```
NetBox Copilot patches circuit status → offline
  → NetBox event rule fires webhook → EDA receives event
  → EDA launches AAP workflow:
    Step 1: Query NetBox, discover backup circuit, derive per-router gateways, push config, update NetBox
    Step 2: Generate HTML incident report, deploy to web server
```

### Key Components

| Component | Details |
|-----------|---------|
| **NetBox** | Source of truth for circuits, sites, devices, interfaces, IPs, cables |
| **EDA Rulebook** | `ansible.eda.webhook` on port 5000, triggers on `circuits.circuit` status change to offline/failed |
| **AAP Workflow** | "Circuit Failover Workflow" — 2 nodes: failover playbook → report deployment |
| **Collections** | `netbox.netbox` (>=3.22.0), `cisco.ios`, `ansible.controller`, `ansible.eda`, `ansible.utils` |
| **Router config** | `cisco.ios.ios_config` for static route changes (or simulated with debug) |
| **Report** | Jinja2 HTML template with topology SVG, bandwidth bars, failover timeline |
| **Infrastructure** | AWS EC2 (optional: report server, Cisco CSR 1000v, NetBox MCP server) or local podman-compose |

### Playbooks

| Playbook | Purpose |
|----------|---------|
| `pb_circuit_failover.yml` | Main logic — query failed circuit, discover backup, derive gateways, push config, update NetBox |
| `pb_deploy_report.yml` | Generate + publish HTML incident report (GitHub Pages or SSH) |
| `pb_reset_demo.yml` | Reset circuits to starting state |
| `pb_seed_netbox.yml` | Populate NetBox with demo data (3 sites, 5 circuits, 3 routers) |
| `pb_setup_aap.yml` | Provision all AAP Controller + EDA objects (idempotent) |

### Integration with LM AIOps (Future)

Potential enhancements for combining with the LogicMonitor solution guide:

1. **LM monitors circuit health** — LM detects latency/packet-loss on WAN circuits, triggers failover before full outage
2. **Edwin AI enrichment for circuit decisions** — Edwin AI correlates circuit alerts with other infrastructure events to determine if failover is the right action or if the root cause is upstream
3. **NetBox as shared CMDB** — Both LM and AAP reference NetBox for network topology; LM alert includes NetBox circuit ID, which the existing failover playbook already handles
4. **Combined reporting** — Incident reports could include LM metrics (latency graphs, packet loss) alongside the NetBox-sourced topology and failover details
5. **Post-failover verification via LM** — After failover, query LM to confirm backup circuit health metrics are within thresholds before closing the incident

### Reusable Patterns

- **Dynamic gateway derivation** — `nthhost(1)` on /30 subnets, no hardcoded IPs
- **AAP bootstrap playbook** — `pb_setup_aap.yml` creates all Controller + EDA objects idempotently using `ansible.controller` modules (similar pattern to our `aap_bootstrap_lm_aiops.yml`)
- **EDA rulebook structure** — Clean webhook → condition → `run_workflow_template` pattern
- **GitHub Pages report publishing** — No infrastructure needed for reports
- **"dd" tag scoping** — All demo objects tagged, queries scoped to tag, prevents cross-contamination with production data

---

## Edwin AI Overview

LogicMonitor's AI-powered ITOps platform.

- **Purpose:** Proactively detect, diagnose, and remediate incidents; reduce alert noise and MTTR
- **API endpoint:** `https://{portal}.dexda.ai/ui/query/records`
- **Record types:** alerts, events, insights
- **Severity filtering:** >= 4
- **Key value:** AI/ML analysis, root cause correlation, intelligent recommendations
- **Integration with AAP:** Edwin AI provides the intelligence; AAP provides governed execution
