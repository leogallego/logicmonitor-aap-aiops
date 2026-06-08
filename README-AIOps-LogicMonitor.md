# LogicMonitor + Ansible Automation Platform: AIOps Solution Guide

<!-- TODO: Add hero image or architecture screenshot when live environment is available -->

**From Alert Noise to Governed Remediation**

Organizations invest heavily in observability, yet most still rely on humans to translate monitoring insights into remediation actions. LogicMonitor and Edwin AI provide the intelligence to detect, analyze, and recommend. Ansible Automation Platform provides the trust layer to govern, execute, and report. Together, they deliver closed-loop AIOps that is safe enough for 3 AM and auditable enough for Monday morning.

This guide walks through a crawl-walk-run maturity progression for BGP network remediation, taking you from simple event-driven automation to AI-enriched workflows to fully agentic AIOps. While the examples focus on networking, the same pattern applies to any infrastructure domain that LogicMonitor monitors -- servers, storage, cloud, and hybrid IT environments.

| | |
|---|---|
| **Operational Impact** | Automated BGP remediation from alert to resolution in seconds (Crawl), AI-enriched root cause routing in minutes (Walk), autonomous investigation of unknown alerts (Run) |
| **Business Value Drivers** | Reduced MTTR, lower on-call escalation volume, faster incident resolution without increasing headcount |
| **Technical Value Drivers** | Event-driven automation (EDA), AI-enriched workflow branching (Edwin AI + set_stats), agentic tool discovery via MCP protocol, governed execution with RBAC and audit trails |

---

## Contents

- [Background](#background)
- [Solution](#solution)
- [Prerequisites](#prerequisites)
- [Integration Architecture](#integration-architecture)
- [Stage 1 -- Crawl: Event-Driven Network Remediation](#stage-1----crawl-event-driven-network-remediation)
- [Stage 2 -- Walk: AI-Enriched Remediation](#stage-2----walk-ai-enriched-remediation)
- [Stage 3 -- Run: Agentic AIOps with MCP](#stage-3----run-agentic-aiops-with-mcp)
- [Validation and Troubleshooting](#validation-and-troubleshooting)
- [Maturity Path Summary](#maturity-path-summary)
- [ROI Recap](#roi-recap)
- [Extending to Hybrid IT](#extending-to-hybrid-it)
- [Demos and Labs](#demos-and-labs)
- [Sources and Next Steps](#sources-and-next-steps)

---

## Background

### The AIOps Gap: Detection Without Action

Alert fatigue is the symptom. The root cause is a gap between intelligence and execution.

Monitoring platforms excel at detecting problems. AI layers excel at correlating signals and recommending fixes. But without a governed execution layer, those recommendations become Slack messages, tickets, and pages to an on-call engineer who may or may not act on them in time.

The fundamental question is this: **if your AI makes a recommendation at 3 AM, what prevents a bad recommendation from reaching production?**

Manual review does not scale. Blind automation introduces unacceptable risk. The answer lies in combining AI intelligence with governed automation.

### LogicMonitor and Edwin AI: The Intelligence Layer

LogicMonitor is a hosted full-stack infrastructure monitoring platform with particular strength in network monitoring. It provides agentless discovery, anomaly detection, and comprehensive alerting across hybrid infrastructure.

Edwin AI is LogicMonitor's AI-powered ITOps layer. It goes beyond simple threshold-based alerting to proactively detect, diagnose, and recommend remediation actions through:

- **Alert correlation** -- grouping related alerts to reduce noise and reveal root causes
- **Event analysis** -- connecting configuration changes, deployments, and infrastructure events to alert patterns
- **Intelligent recommendations** -- suggesting specific remediation actions based on historical patterns and current context

### Ansible Automation Platform: The Trust Layer

Red Hat Ansible Automation Platform provides the governance framework that makes AI-recommended automation safe for production:

- **RBAC** -- controlling who can create, modify, and execute automation
- **Policy as Code** -- defining what automation is allowed to do and under what conditions
- **Approval workflows** -- requiring human sign-off for high-risk actions
- **Audit trails** -- recording every action, every parameter, and every outcome
- **Deterministic execution** -- ensuring the same automation produces the same result every time
- **Event-Driven Ansible** -- reacting to external events in real time with governed rule evaluation

LogicMonitor and Edwin AI provide the intelligence. AAP provides the trust layer. Neither platform can deliver closed-loop AIOps alone.

---

## Solution

### Components

| Component | Role | Details |
|-----------|------|---------|
| **LogicMonitor** | Detection and monitoring | Full-stack infrastructure monitoring, webhook-based alerting |
| **Edwin AI** | Analysis and recommendation | Alert correlation, root cause analysis, remediation recommendations |
| **AAP Automation Controller** | Governed execution | Job templates, workflow templates, RBAC, audit logging |
| **AAP EDA Controller** | Event-driven automation | Rulebook activations, event stream processing, webhook ingestion |
| **AAP MCP Server** | Agentic AI interface | Enables Edwin AI to discover and invoke AAP automation within RBAC boundaries |
| **Network infrastructure** | Target infrastructure | Network devices monitored by LogicMonitor (examples in this guide use Arista EOS) |

### Personas

| Persona | Challenge | What They Gain |
|---------|-----------|----------------|
| **Network Operations** | Manual triage of BGP alerts; slow MTTR; alert fatigue from repetitive incidents | Known issues resolve in seconds. Ambiguous failures are triaged by AI. On-call engineers handle only truly novel problems. |
| **Platform Engineering** | Remediation logic lives in tribal knowledge; no governed way to encode decision trees | Every action runs through pre-tested job templates with RBAC. Workflow templates encode decision logic. Patterns promote from ad-hoc to governed. |
| **Security and Compliance** | No audit trail for manual remediation; AI actions bypass governance | Every alert, decision, and action is logged. Policy as Code enforces boundaries. Human approval gates at any point in the chain. |

---

## Prerequisites

| Requirement | Version / Details |
|-------------|-------------------|
| Ansible Automation Platform | 2.6 (Automation Controller + EDA Controller) |
| LogicMonitor | Active account with API access and webhook configuration |
| Edwin AI | Portal with API credentials (`access_id`, `access_key`) |
| AAP MCP Server | Deployed alongside AAP (Technology Preview in AAP 2.6) |
| Network devices | Devices monitored by LogicMonitor with BGP peering (examples use Arista EOS) |

### Collections

| Collection | Purpose |
|------------|---------|
| `logicmonitor.integration` | LM device management (devices, collectors, alert rules, device groups) |
| `logicmonitor.edwin_ai` | Edwin AI query API for alert correlation and insights |
| `arista.eos` | Network device automation (substitute your platform's collection as needed) |
| `ansible.eda` | Event-Driven Ansible webhook source plugin |

---

## Integration Architecture

### AIOps Value Chain

The integration maps cleanly across the AIOps value chain, with LogicMonitor and Edwin AI owning the left side (intelligence) and AAP owning the right side (execution):

```
  LogicMonitor / Edwin AI                 AAP
  +------------------------------+  +------------------------------+
  | DETECT -> ANALYZE -> RECOMMEND |  | GOVERN -> EXECUTE -> REPORT  |
  |                                |  |                              |
  | LM monitors infrastructure    |  | RBAC, Policy as Code         |
  | Edwin AI correlates alerts     |  | Pre-tested job templates     |
  | Edwin AI recommends actions    |  | Workflow orchestration       |
  |                                |  | Audit trails                 |
  +------------------------------+  +------------------------------+
```

### Overall Architecture

```
+---------------------------------------------------------------------+
|                        LOGICMONITOR                                   |
|  +----------+    +----------+    +------------------------------+    |
|  | Detection |-->| Analysis |-->| Edwin AI (Recommendations)    |    |
|  | Engine    |   | (AI/ML)  |   |                                |   |
|  +----------+    +----------+    +------+--------------+---------+   |
|                                         |              |             |
+-----------------------------------------|--------------|-------------+
                                          |              |
                        Webhook (alerts)  |              | MCP (agentic)
                                          |              |
+-----------------------------------------|--------------|-------------+
|                  ANSIBLE AUTOMATION PLATFORM                         |
|                                         |              |             |
|  +------------------+    +--------------v--+   +-------v--------+   |
|  | EDA Controller   |    | Automation      |   | AAP MCP Server |   |
|  |                  |    | Controller      |   |                |   |
|  | Event Streams    |--->| Job Templates   |<--| Tool discovery |   |
|  | Rulebook         |    | Workflows       |   | RBAC enforced  |   |
|  | Activations      |    | RBAC / PaC      |   | Human approval |   |
|  +------------------+    | Audit Logging   |   +----------------+   |
|                          +--------+--------+                        |
|                                   |                                 |
|                    +--------------v--------------+                  |
|                    | Content Collections          |                  |
|                    | logicmonitor.integration     |                  |
|                    | logicmonitor.edwin_ai        |                  |
|                    | arista.eos                   |                  |
|                    +--------------+--------------+                  |
|                                   |                                 |
+-----------------------------------|---------------------------------+
                                    |
                    +---------------v---------------+
                    |    TARGET INFRASTRUCTURE       |
                    |  Network devices monitored     |
                    |  by LogicMonitor                |
                    +-------------------------------+
```

### Integration Surfaces

Four integration surfaces are used across the three maturity stages:

| Surface | Component | Stage | Role |
|---------|-----------|-------|------|
| **EDA webhook** | `ansible.eda.webhook` source plugin | All | Receives LM alert webhooks into EDA Event Streams |
| **LM device management** | `logicmonitor.integration` collection | All | Manages LM devices, collectors, alert rules, device groups |
| **Edwin AI query** | `logicmonitor.edwin_ai.query_api` module | Walk, Run | Queries Edwin AI for correlated alerts, events, insights |
| **AAP MCP Server** | `ansible/aap-mcp-server` | Run | Enables Edwin AI to discover and invoke AAP automation |

### Integration Patterns

Each maturity stage uses a different integration pattern with AAP. The patterns differ in how they are triggered, how tightly they couple the partner platform to AAP, and how governance is enforced:

| | **EDA (Crawl)** | **Direct API (Walk)** | **MCP Server (Run)** |
|---|---|---|---|
| **Trigger** | Events from buses and webhooks | HTTP request from playbook | Natural language / AI |
| **Coupling** | Loose (event-based, fire-and-forget) | Tight (ID-based, request/response) | Abstracted (agent-based, protocol-enforced) |
| **Primary user** | Monitoring / Observability / ITSM | Custom apps / Scripts | AI agents / Humans |
| **Governance** | Rule-defined (rulebook conditions) | Token-based (API credentials) | Protocol-enforced (RBAC via MCP) |
| **Response model** | Asynchronous | Synchronous | Synchronous (bidirectional) |

The crawl-walk-run progression moves from left to right across these patterns, with each stage adding integration depth while maintaining AAP's governance guarantees.

---

## Stage 1 -- Crawl: Event-Driven Network Remediation

- **Integration surface:** EDA webhook
- **Operational impact:** Low -- deterministic remediation of known alerts, no AI dependency
- **Story:** Known alert, known fix. Deterministic, no AI involved.

The Crawl stage handles the simplest and most common case: a well-understood alert type with a pre-defined remediation playbook. There is no AI enrichment and no agentic behavior. The EDA rulebook matches the alert type and triggers the corresponding job template.

### Flow

```
LM detects BGP peer down on network device
  -> LM sends webhook (HTTP POST) to EDA Event Stream
    -> Rulebook activation evaluates alert
      -> Condition matches: alert_type == "bgp_peer_down"
        -> Triggers Job Template: "Reset BGP Session"
          -> Playbook resets BGP neighbor on affected device
            -> Validates BGP re-establishes
              -> Reports back to LM (acknowledge/annotate alert)
```

### Setup

1. **Configure the LogicMonitor webhook.** In the LM portal, create an integration that sends HTTP POST alerts to your EDA Controller's event stream endpoint. The webhook URL follows the pattern `https://<eda-controller>:5000/logicmonitor`.

2. **Deploy the EDA rulebook.** Create a rulebook activation in the EDA Controller using the rulebook at `rulebooks/logicmonitor_network.yml`. The Crawl-stage rule matches on `event.payload.type == "bgp_peer_down"`.

3. **Create the job template.** Using the AAP bootstrap playbook at `lab-automation/aap_bootstrap_lm_aiops.yml`, or manually, create the "Reset BGP Session" job template:

| Field | Value |
|-------|-------|
| Name | Reset BGP Session |
| Job Type | Run |
| Organization | Network Ops |
| Project | LM AIOps Solution Guide |
| Playbook | `playbooks/reset_bgp_session.yml` |
| Inventory | Network Inventory |
| Credentials | Machine Credential |
| Ask Variables on Launch | Yes |
| Extra Variables | `affected_host` (from EDA), `alert_id` (from EDA) |

### Use Case: BGP Peer Down -- Reset Session

A BGP neighbor relationship drops to IDLE state on one router, causing a network segment to become unreachable. LogicMonitor detects the state change, fires a critical alert, and the webhook delivers it to EDA.

The rulebook evaluates the alert and matches the Crawl rule:

```yaml
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
```

The "Reset BGP Session" job template (`playbooks/reset_bgp_session.yml`) targets the affected device, clears all BGP sessions, waits for peers to re-establish, and validates the recovery. On success, it reports the remediation result back to LogicMonitor via `playbooks/report_to_logicmonitor.yml`, which acknowledges and annotates the alert:

```yaml
# Note: The logicmonitor.integration collection does not yet include an alert
# acknowledgment module. This task uses ansible.builtin.uri as a placeholder
# until native module support is available.
- name: Acknowledge alert in LogicMonitor
  ansible.builtin.uri:
    url: "https://{{ lm_company }}.logicmonitor.com/santaba/rest/alert/alerts/{{ alert_id }}/ack"
    method: POST
    headers:
      Authorization: "Bearer {{ lm_bearer_token }}"
      Content-Type: "application/json"
    body_format: json
    body:
      ackComment: >-
        Automated remediation by AAP: {{ remediation_result }}
        on host {{ remediation_host }}.
    status_code: [200, 202]
```

### Validation

Once configured, trigger a real or test BGP peer down alert in LogicMonitor. Verify in the AAP Controller that the "Reset BGP Session" job launches targeting the correct host.

**Expected result in AAP Controller:**

```
PLAY [Reset BGP session on affected device] ************************************

TASK [Assert BGP peers are established] ****************************************
ok: [affected-device] => {
    "changed": false,
    "msg": "BGP peers successfully re-established"
}

PLAY RECAP *********************************************************************
affected-device            : ok=6    changed=0    unreachable=0    failed=0
```

For hands-on testing with a lab environment, see the [Demo Guide](README-AIOps-LogicMonitor-Demo.md).

### Components

| Component | Details |
|-----------|---------|
| EDA source | `ansible.eda.webhook` on EDA Event Stream |
| Rulebook | Single rule matching `bgp_peer_down` |
| Job Template | "Reset BGP Session" |
| Playbook | `playbooks/reset_bgp_session.yml` |
| Collections | `arista.eos`, `logicmonitor.integration` |

---

## Stage 2 -- Walk: AI-Enriched Remediation

- **Integration surface:** EDA webhook + Edwin AI query API
- **Operational impact:** Medium -- adds Edwin AI dependency for enrichment, with Crawl-stage fallback if unavailable
- **Story:** Known alert, but the right fix depends on root cause. Edwin AI provides the context that determines which remediation branch to run.

The Walk stage handles alerts where the symptom is well-known but the underlying cause varies. Rather than always applying the same fix, the workflow first queries Edwin AI for correlated alerts and insights, determines the most likely root cause, and then branches to the appropriate remediation playbook.

### Flow

```
LM detects BGP flapping on network device
  -> LM sends webhook to EDA Event Stream
    -> Rulebook activation evaluates alert
      -> Condition matches: alert_type == "bgp_flapping"
        -> Triggers Workflow Template: "BGP Smart Remediation"
          -> Node 1: "Enrich with Edwin AI"
          |   -> query_api: get correlated alerts and insights
          |   -> sets workflow artifacts (root_cause, correlated_alerts)
          |
          +-- root_cause == "interface_errors"
          |   -> Node 2a: "Bounce Interface"
          |
          +-- root_cause == "cpu_exhaustion"
          |   -> Node 2b: "Restart Routing Process"
          |
          +-- root_cause == "config_drift"
          |   -> Node 2c: "Rollback Configuration"
          |
          +-- Edwin AI unreachable (failure fallback)
              -> Node 2d: "Default BGP Reset" (same as Crawl)
```

### Setup

1. **Configure Edwin AI credentials.** Using the AAP bootstrap (`lab-automation/aap_bootstrap_lm_aiops.yml`), create the "Edwin AI API" custom credential type and attach it to the enrichment job template:

```yaml
# Custom credential type: Edwin AI API
inputs:
  fields:
    - id: edwin_portal
      label: "Edwin AI Portal"
      type: string
    - id: edwin_access_id
      label: "Edwin AI Access ID"
      type: string
    - id: edwin_access_key
      label: "Edwin AI Access Key"
      type: string
      secret: true
injectors:
  extra_vars:
    edwin_portal: "{{ edwin_portal }}"
    edwin_access_id: "{{ edwin_access_id }}"
    edwin_access_key: "{{ edwin_access_key }}"
```

2. **Create the workflow job templates.** The workflow nodes require these job templates (created by the AAP bootstrap or manually):

| Field | Enrich with Edwin AI | Bounce Interface | Restart Routing | Rollback Config |
|-------|---------------------|------------------|-----------------|-----------------|
| Job Type | Run | Run | Run | Run |
| Organization | Network Ops | Network Ops | Network Ops | Network Ops |
| Project | LM AIOps Solution Guide | LM AIOps Solution Guide | LM AIOps Solution Guide | LM AIOps Solution Guide |
| Playbook | `playbooks/enrich_with_edwin_ai.yml` | `playbooks/bounce_interface.yml` | `playbooks/restart_routing.yml` | `playbooks/rollback_config.yml` |
| Inventory | Network Inventory | BGP Lab Inventory | BGP Lab Inventory | BGP Lab Inventory |
| Credentials | Edwin AI API, Machine Credential | Machine Credential | Machine Credential | Machine Credential |
| Ask Variables on Launch | Yes | Yes | Yes | Yes |

3. **Create the workflow template.** Build the "BGP Smart Remediation" workflow in AAP Controller with the following topology:

```
+----------------------+
| Enrich with Edwin AI |
| (query_api)          |
+-----------+----------+
            |
    +-------+--------+--------+
    |                |        |
    v                v        v
+---------+ +----------+ +----------+
| Bounce  | | Restart  | | Rollback |
| Iface   | | Routing  | | Config   |
+---------+ +----------+ +----------+
                               |
                         (on failure)
                               |
                               v
                        +-------------+
                        | Default BGP |
                        | Reset       |
                        +-------------+
```

The workflow uses convergence nodes: each remediation branch runs based on the `root_cause` artifact set by the enrichment node. The failure fallback ensures that even if Edwin AI is unreachable, the workflow still performs a best-effort remediation using the Crawl-stage reset.

### Use Case: BGP Flapping -- Multiple Root Causes

BGP sessions are flapping (repeatedly going up and down) on a router. The surface symptom is the same every time, but the root cause varies. Without AI enrichment, the rulebook would trigger the same fixed remediation every time. With Edwin AI, the workflow queries for correlated alerts and gets context to make a smarter decision:

| Edwin AI finds | Root cause | Workflow branch |
|----------------|------------|-----------------|
| BGP flapping + interface error counters spiking | Bad link or cable | Bounce the interface (`playbooks/bounce_interface.yml`) |
| BGP flapping + CPU at 98% on the device | Resource exhaustion | Restart routing process (`playbooks/restart_routing.yml`) |
| BGP flapping + config change event 5 minutes ago | Config drift | Roll back to last known good config (`playbooks/rollback_config.yml`) |
| Only BGP flapping, no correlated alerts | Unknown / transient | Default BGP reset (Crawl fallback) |

The enrichment playbook (`playbooks/enrich_with_edwin_ai.yml`) uses `logicmonitor.edwin_ai.query_api` to query Edwin AI for recent alerts and insights on the affected device:

```yaml
- name: Query Edwin AI for correlated alerts
  logicmonitor.edwin_ai.query_api:
    portal: "{{ edwin_portal }}"
    access_id: "{{ edwin_access_id }}"
    access_key: "{{ edwin_access_key }}"
    record_type: alerts
    limit: 20
    lookback_window: "{{ edwin_lookback_window }}"
  register: __edwin_alerts
```

It processes the response, determines the most likely root cause via correlated alert type analysis, and passes the finding as a workflow artifact using `ansible.builtin.set_stats`:

```yaml
- name: Set workflow artifacts for downstream nodes
  ansible.builtin.set_stats:
    data:
      root_cause: "{{ __root_cause | trim }}"
      correlated_alert_count: "{{ __correlated_alerts | length }}"
      affected_host: "{{ affected_host }}"
      alert_id: "{{ alert_id }}"
```

The EDA rulebook rule for the Walk stage:

```yaml
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
```

### Alternative: Pre-EDA Enrichment

If Edwin AI supports outbound webhooks or enriched alert forwarding, it can pre-enrich events before they reach EDA. In this model, Edwin AI analyzes the alert, appends root cause context to the payload, and sends the enriched event to EDA. The rulebook then has richer conditions to route directly to the correct job template without needing a workflow. This approach reduces latency but moves intelligence outside of AAP's governed workflow boundary. Consider this pattern for deployments where Edwin AI supports it and the governance tradeoff is acceptable.

### Validation

Trigger a BGP flapping alert in LogicMonitor. Verify in the AAP Controller that the "BGP Smart Remediation" workflow launches, the enrichment node runs first, and the correct remediation branch executes based on the Edwin AI response.

**Expected result in AAP Controller:**

```
Workflow "BGP Smart Remediation" -- Status: Successful

  Node 1: "Enrich with Edwin AI"     -- Status: Successful
    Artifacts: root_cause=interface_errors, correlated_alert_count=3

  Node 2a: "Bounce Interface"        -- Status: Successful
    (Selected based on root_cause artifact)

  Node 3: "Report to LogicMonitor"   -- Status: Successful
```

For hands-on testing with a lab environment, see the [Demo Guide](README-AIOps-LogicMonitor-Demo.md).

### Components

| Component | Details |
|-----------|---------|
| EDA source | `ansible.eda.webhook` (same as Crawl) |
| Rulebook | Adds `bgp_flapping` -> workflow rule |
| Workflow Template | "BGP Smart Remediation" (5-6 nodes) |
| Enrichment playbook | `playbooks/enrich_with_edwin_ai.yml` (uses `logicmonitor.edwin_ai.query_api`) |
| Remediation playbooks | `playbooks/bounce_interface.yml`, `playbooks/restart_routing.yml`, `playbooks/rollback_config.yml` |
| Collections | `arista.eos`, `logicmonitor.integration`, `logicmonitor.edwin_ai` |

---

## Stage 3 -- Run: Agentic AIOps with MCP

- **Integration surface:** EDA webhook + AAP MCP Server
- **Operational impact:** High -- agentic AI investigation with MCP, requires AAP MCP Server and Edwin AI connectivity
- **Story:** Unknown alert -- no rulebook rule matches. Instead of dropping the event or paging a human, EDA escalates to Edwin AI, which investigates and acts as an intelligent agent via the AAP MCP Server.

The Run stage handles the long tail of alerts that do not match any explicit rulebook rule. This is where the gap is widest in traditional operations: novel alert types, cascading failures, alerts from recently onboarded device types, or unusual combinations that have never been codified into runbooks. These events typically result in pages to the on-call team. With Run-stage AIOps, Edwin AI picks up the investigation.

### Flow

```
LM sends alert that doesn't match any explicit rulebook rule
  -> LM webhook to EDA Event Stream
    -> Rulebook activation evaluates alert
      -> No specific rule matches
        -> Catch-all rule fires: "Escalate to Edwin AI"
          -> Job Template passes raw alert context to Edwin AI
            -> Edwin AI analyzes the alert
              -> Edwin AI connects to AAP MCP Server
                -> Discovers available job/workflow templates (within RBAC)
                -> Queries inventory (which devices, groups)
                -> Checks recent job history
                -> Recommends: "Run 'X' workflow on device Y"
              -> Human approves (or auto-approve for known patterns)
                -> AAP MCP Server launches the workflow
                  -> AAP executes remediation
                    -> Results flow back to LM
```

### Setup

1. **Deploy the AAP MCP Server.** Install `ansible/aap-mcp-server` alongside your AAP deployment. The MCP server dynamically generates tools from AAP's OpenAPI specifications, wrapping Controller, Galaxy, EDA, and Gateway endpoints.

2. **Configure toolsets.** Enable at minimum the `job_management` and `inventory_management` toolsets. These allow Edwin AI to discover job templates, query inventory hosts, check job history, and launch automation -- all within the boundaries of the authenticated user's RBAC permissions.

3. **Create the escalation job template.** The "Escalate to Edwin AI" template (`playbooks/escalate_to_edwin_ai.yml`) receives the raw alert payload from the catch-all rule and sends it to Edwin AI for investigation.

| Field | Value |
|-------|-------|
| Name | Escalate to Edwin AI |
| Job Type | Run |
| Organization | Network Ops |
| Project | LM AIOps Solution Guide |
| Playbook | `playbooks/escalate_to_edwin_ai.yml` |
| Inventory | Network Inventory |
| Credentials | Edwin AI API, Machine Credential |
| Ask Variables on Launch | Yes |
| Extra Variables | `raw_alert` (from EDA), `source` (from EDA) |

### Use Case: Unknown Network Degradation

LogicMonitor detects an unusual pattern -- a novel alert type or combination that does not match any existing rulebook rule. The catch-all rule in the EDA rulebook fires:

```yaml
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

Because the rules in the rulebook are evaluated in order (most specific first), the catch-all only fires when no Crawl or Walk rule has matched.

### What Edwin AI Does via MCP

Once Edwin AI receives the escalation, it connects to the AAP MCP Server and proceeds through an investigation workflow:

1. Receives the raw alert context from the escalation playbook
2. Connects to the AAP MCP Server using the authenticated user's permissions
3. Discovers available job templates and workflow templates
4. Queries the inventory to understand the affected infrastructure
5. Checks recent job history -- has similar automation been tried on this device before?
6. Formulates a recommendation: which automation to run, on which hosts, with what parameters
7. Presents the recommendation for human approval (or auto-approves based on policy)
8. The AAP MCP Server triggers the approved automation
9. Results are returned and reported back to LogicMonitor

Every action Edwin AI takes through the MCP Server is governed by the same RBAC policies that apply to human operators. It can only discover and invoke automation that the authenticated user is authorized to use.

### Pattern Promotion

The Run stage is not a permanent catch-all. As Edwin AI successfully handles certain alert patterns via MCP, those patterns are promoted to Walk or Crawl rules over time. See [The Promotion Pattern](#the-promotion-pattern) for details.

### Going Further: Community LM MCP Server

The community `logicmonitor-mcp-server` (125 tools wrapping LM's REST API) can complement the Run stage by enabling AI agents or AAP playbooks to query LogicMonitor directly for device details, alert history, dashboard data, collector status, and topology information. This adds bidirectional depth -- Edwin AI can not only act through AAP but also query LM for richer context during investigation. The community server is not required for the core Run flow but extends the integration surface for teams that want maximum visibility.

### Validation

Send an alert type that does not match any explicit Crawl or Walk rule. Verify in the AAP Controller that the "Escalate to Edwin AI" job launches and the alert context reaches Edwin AI for MCP-based investigation.

**Expected result in AAP Controller:**

The "Escalate to Edwin AI" job completes successfully. Edwin AI receives the alert context and begins investigation via the AAP MCP Server, discovering available templates and recommending remediation.

<!-- TODO: Add screenshot of AAP job log showing escalation when live environment is available -->

For hands-on testing with a lab environment, see the [Demo Guide](README-AIOps-LogicMonitor-Demo.md).

### Components

| Component | Details |
|-----------|---------|
| EDA source | `ansible.eda.webhook` (same as Crawl/Walk) |
| Rulebook | Adds catch-all escalation rule (lowest priority) |
| Job Template | "Escalate to Edwin AI" |
| Escalation playbook | `playbooks/escalate_to_edwin_ai.yml` -- sends alert context to Edwin AI |
| AAP MCP Server | `ansible/aap-mcp-server` deployed alongside AAP |
| MCP Toolsets | `job_management`, `inventory_management` at minimum |
| Optional | Community LM MCP Server for bidirectional LM exploration |
| Collections | `logicmonitor.integration`, `logicmonitor.edwin_ai` |

---

## Validation and Troubleshooting

### Per-Stage Validation Checklist

| Stage | Validation step | Expected result |
|-------|----------------|-----------------|
| **Crawl** | BGP peer down alert fires in LogicMonitor | Webhook delivered to EDA Event Stream |
| **Crawl** | EDA rulebook evaluates alert | "Reset BGP Session" job launches targeting correct host |
| **Crawl** | Check LM alert after remediation | Alert acknowledged with AAP annotation |
| **Walk** | BGP flapping alert fires in LogicMonitor | "BGP Smart Remediation" workflow launches |
| **Walk** | Verify workflow node execution | Enrichment node runs first, correct branch follows based on root cause |
| **Walk** | Edwin AI returns correlated alerts | Workflow selects appropriate remediation (bounce, rollback, or default reset) |
| **Run** | Unmatched alert type fires in LogicMonitor | Catch-all rule triggers "Escalate to Edwin AI" job |
| **Run** | Verify Edwin AI MCP interaction | Edwin AI discovers AAP templates, recommends action |
| **Run** | Check AAP audit log | Escalation and any MCP-triggered actions are logged |

### Common Issues

| Issue | Cause | Resolution |
|-------|-------|------------|
| Webhook not reaching EDA | Firewall, incorrect URL, or EDA activation not running | Verify network connectivity to EDA port 5000; check rulebook activation status in EDA Controller |
| BGP not re-establishing after reset | Hold timer not expired, or underlying link still down | Increase wait timeout in `playbooks/reset_bgp_session.yml`; verify link connectivity on affected device |
| Edwin AI query returns empty results | Incorrect credentials, wrong portal name, or no alerts in lookback window | Verify Edwin AI credential type is attached to the job template; check `edwin_lookback_window` value |
| Edwin AI timeout during enrichment | Network latency or Edwin AI portal outage | The workflow failure fallback triggers the default BGP reset (Crawl behavior) |
| MCP Server not connecting | AAP MCP Server not deployed, or toolsets not enabled | Verify `aap-mcp-server` is running; check toolset configuration |
| Wrong remediation branch in Walk | Root cause logic mismatch in enrichment playbook | Review `playbooks/enrich_with_edwin_ai.yml` Jinja2 logic against Edwin AI response structure |
| Catch-all rule fires for known alerts | Rulebook rule ordering issue | Ensure specific Crawl/Walk rules appear before the Run catch-all in `rulebooks/logicmonitor_network.yml` |

---

## Maturity Path Summary

### Progression

```
  CRAWL                    WALK                     RUN
  Known alert,             Known alert,             Unknown alert,
  known fix                AI-enriched fix          agentic investigation

  EDA --> Job Template     EDA --> Workflow          EDA --> Catch-all
                           (Edwin AI enrichment)    (Edwin AI + MCP)

  Deterministic            Smart branching          Autonomous discovery
  Seconds                  Minutes                  Minutes (vs. hours manual)

              <--- Pattern promotion over time ---
              Successful Run patterns become Walk rules
              Successful Walk patterns become Crawl rules
```

### When to Advance

**From Crawl to Walk:** Advance when you have alert types where the same symptom has multiple root causes and you find your team manually triaging which remediation to apply. The Walk stage automates that triage by adding Edwin AI enrichment.

**From Walk to Run:** Advance when you have the AAP MCP Server deployed and you want to handle the long tail of alerts that do not match any existing rule. The Run stage is appropriate once your Crawl and Walk rules cover the most common scenarios and you want to reduce the on-call burden for everything else.

### The Promotion Pattern

The crawl-walk-run framework is not just an adoption path -- it is an ongoing operational pattern. As the Run stage handles novel alerts and the team observes which patterns recur:

1. **A recurring Run pattern** where Edwin AI consistently recommends the same workflow gets promoted to a Walk rule with explicit enrichment logic.
2. **A recurring Walk pattern** where Edwin AI consistently identifies the same root cause gets promoted to a Crawl rule with deterministic remediation.
3. **The catch-all shrinks** as explicit rules grow, and the overall system becomes more efficient and predictable over time.

---

## ROI Recap

### MTTR Reduction

- **Crawl:** Known issues go from minutes of human response to seconds of automated remediation. No triage, no handoff, no context switching.
- **Walk:** Ambiguous failures go from hours of manual investigation to minutes of AI-enriched, governed workflow execution. The right fix is applied the first time.
- **Run:** Unknown alerts that would have languished in a queue or escalated blindly are now investigated by Edwin AI in minutes. The on-call team handles only the truly novel problems that remain after AI investigation.

### Alert Noise Reduction

Edwin AI's alert correlation reduces the volume of events that reach the on-call team. Combined with EDA's event-driven processing, most alerts are handled without human intervention. The team's attention is focused on high-value work rather than repetitive remediation.

### Governance and Audit Readiness

Every remediation action -- whether triggered by a Crawl rule, a Walk workflow, or a Run-stage MCP interaction -- flows through AAP's governance framework. This means:

- Complete audit trails for every action taken
- RBAC enforcement on all automation, including AI-initiated actions
- Policy as Code ensuring automation stays within approved boundaries
- Approval workflows for high-risk operations

### Suggested Metrics

Track these metrics to quantify the value of each stage:

| Metric | What it measures | Target |
|--------|-----------------|--------|
| MTTR by stage | Time from alert to resolution for Crawl, Walk, and Run incidents | Crawl: < 60s, Walk: < 5m, Run: < 15m |
| Remediation success rate | Percentage of automated remediations that resolve the issue | > 95% for Crawl, > 85% for Walk |
| On-call escalation reduction | Change in pages to on-call engineers | 30-50% reduction after Walk, 50-70% after Run |
| Alert noise reduction | Volume of alerts reaching human operators | Measurable decrease as Crawl rules expand |
| Pattern promotion rate | Number of Run patterns promoted to Walk/Crawl per quarter | Indicates system maturity growth |

---

## Extending to Hybrid IT

This guide uses BGP network remediation as the reference scenario because network alerts are concrete, easy to simulate, and immediately relatable to operations teams. However, the crawl-walk-run pattern and every integration surface described here apply to any infrastructure domain that LogicMonitor monitors.

| Domain | Crawl example | Walk example | Run example |
|--------|--------------|--------------|-------------|
| **Server / OS** | Disk usage alert -> extend LVM | High memory + OOM alerts -> Edwin AI determines leaking process vs. capacity -> targeted restart or scale-out | Unknown performance degradation -> Edwin AI investigates via MCP |
| **Cloud** | Cloud budget threshold -> rightsizing job | Latency spike + deployment event -> rollback vs. config adjustment | Novel cloud service alert -> agentic investigation |
| **Storage** | Array health alert -> failover path check | I/O latency + firmware event correlation -> firmware update vs. rebalance | Cascading storage alerts -> Edwin AI triages across arrays |

The architecture remains the same: LogicMonitor detects, Edwin AI analyzes, and AAP governs execution. Only the content collections and remediation playbooks change per domain. Teams that start with network can expand to additional domains by adding new rulebook rules, job templates, and the appropriate content collections.

---

## Demos and Labs

| Resource | Status | Description |
|----------|--------|-------------|
| [Demo Guide](README-AIOps-LogicMonitor-Demo.md) | Available | Step-by-step lab setup with ContainerLab, Arista cEOS, incident simulation playbooks, and validation scripts |
| Video walkthrough | Planned | Recorded demo showing the crawl-walk-run progression end-to-end |
| Live demo environment | Planned | Pre-configured environment with LogicMonitor, AAP 2.6, and all three stages ready to run |

---

## Sources and Next Steps

### Resources

| Resource | Link |
|----------|------|
| `logicmonitor.integration` collection | [Automation Hub](https://console.redhat.com/ansible/automation-hub/collections/published/logicmonitor/integration) |
| `logicmonitor.edwin_ai` collection | [Automation Hub](https://console.redhat.com/ansible/automation-hub/collections/published/logicmonitor/edwin_ai) |
| AAP MCP Server | [GitHub](https://github.com/ansible/aap-mcp-server) |
| Community LM MCP Server | [GitHub](https://github.com/monitoringartist/logicmonitor-mcp-server) |
| Solution Guides | [ansible-tmm.github.io/solution-guides](https://ansible-tmm.github.io/solution-guides/) |

### Related Solution Guides

- [**Instana + AAP**](https://ansible-tmm.github.io/solution-guides/Instana-AIOps/) -- Observability-driven automation with IBM Instana
- [**Splunk + AAP**](https://ansible-tmm.github.io/solution-guides/AIOps-Splunk-ITSI/) -- SIEM-driven event response and remediation
- [**ServiceNow + AAP**](https://ansible-tmm.github.io/solution-guides/AIOps-ServiceNow/) -- ITSM-integrated change management and incident response

### Next Steps

1. **Start with Crawl.** Deploy the EDA rulebook and the "Reset BGP Session" job template. Configure the LogicMonitor webhook. Validate that known BGP alerts trigger deterministic remediation. This can be running in production within a day.

2. **Expand to Walk.** Once Crawl-stage automation is proven, add the Edwin AI enrichment workflow. Configure Edwin AI credentials. Build the "BGP Smart Remediation" workflow template. Start with a single ambiguous alert type and expand as the team gains confidence.

3. **Explore Run.** When the AAP MCP Server is available in your environment, deploy the catch-all escalation rule. Start with human approval required for all MCP-initiated actions. As patterns emerge and trust builds, selectively enable auto-approval for low-risk, high-confidence recommendations.

The crawl-walk-run progression is designed to meet teams where they are. Each stage delivers immediate value while building the foundation for the next.
