# LogicMonitor + AAP AIOps Solution Guide — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a complete AIOps solution guide and demo showing LogicMonitor + Edwin AI + AAP integration with a crawl-walk-run maturity progression for network (BGP) remediation.

**Architecture:** Three maturity stages share a single EDA webhook pipeline. Crawl uses a simple job template for deterministic BGP reset. Walk adds an AAP workflow that queries Edwin AI for root cause context before branching to the right remediation. Run adds a catch-all rule that escalates unmatched alerts to Edwin AI, which acts as an agent via the AAP MCP Server.

**Tech Stack:** Ansible Automation Platform 2.6, Event-Driven Ansible, ContainerLab with Arista cEOS, LogicMonitor, Edwin AI, AAP MCP Server, `arista.eos` / `logicmonitor.integration` / `logicmonitor.edwin_ai` collections.

**Base Infrastructure:** The `zt-network-automation-workshop` repo (local copy at `/home/lgallego/Claude/zt-network-automation-workshop`) provides reusable RHDP infrastructure: ContainerLab VM image with auto-resume, AAP 2.6 Controller with bootstrap automation (`ansible.controller` modules for orgs, inventories, credentials, job templates, RBAC), Arista group vars, and LB port-forwarding patterns. We build our BGP topology, EDA components, workflow templates, and LM/Edwin AI integration on top of this foundation. See `resources/reference.md` section "Network Lab Base" for full details.

**Note on LM API access:** Several tasks require live LogicMonitor and Edwin AI API access (not yet available). These steps are marked with `[REQUIRES LM ACCESS]` and should use placeholder values until credentials are available, then be updated with real payload structures.

---

## File Map

```
logicmonitor/
├── README-AIOps-LogicMonitor.md          # The solution guide (main deliverable)
├── containerlab/
│   └── bgp-topology.yml                  # ContainerLab topology definition (3 Arista cEOS eBGP mesh)
├── playbooks/
│   ├── reset_bgp_session.yml             # Crawl: reset BGP neighbor
│   ├── validate_bgp.yml                  # Shared: validate BGP state
│   ├── report_to_logicmonitor.yml        # Shared: acknowledge/annotate LM alert
│   ├── enrich_with_edwin_ai.yml          # Walk: query Edwin AI, set workflow artifacts
│   ├── bounce_interface.yml              # Walk: bounce interface on device
│   ├── rollback_config.yml               # Walk: rollback config to last known good
│   ├── escalate_to_edwin_ai.yml          # Run: send alert context to Edwin AI
│   ├── simulate_bgp_down.yml             # Simulation: break BGP by shutting interface
│   ├── simulate_interface_errors.yml     # Simulation: interface errors + BGP flapping
│   ├── simulate_config_drift.yml         # Simulation: change BGP config
│   └── simulate_unknown_alert.yml        # Simulation: send unmatched alert via curl
├── lab-automation/
│   └── aap_bootstrap_lm_aiops.yml        # AAP Controller bootstrap: LM-specific job/workflow templates, EDA objects
├── rulebooks/
│   └── logicmonitor_network.yml          # Tiered EDA rulebook (crawl/walk/run rules)
├── inventory/
│   ├── hosts.yml                         # ContainerLab device inventory
│   └── group_vars/
│       └── arista.yml                    # Arista cEOS connection vars
├── validation/
│   ├── test_crawl.sh                     # curl + verification for Crawl stage
│   ├── test_walk.sh                      # curl + verification for Walk stage
│   └── test_run.sh                       # curl + verification for Run stage
├── collections/
│   └── leogallego.logicmonitor_mcp/      # (existing) custom MCP-based LM collection
├── resources/
│   └── reference.md                      # (existing) resource reference doc
└── docs/
    └── superpowers/
        ├── specs/                         # (existing) design spec
        └── plans/                         # this plan

# Base infrastructure (not in this repo, adapted from):
# /home/lgallego/Claude/zt-network-automation-workshop/
#   lab-automation/playbooks/aap_bootstrap.yml          — AAP bootstrap pattern (orgs, inventories, creds, RBAC)
#   lab-automation/playbooks/tasks/controller_*.yml      — Controller object creation tasks
#   lab-automation/inventory/                            — Inventory structure + group_vars pattern
#   setup-automation/setup-containerlab.sh               — ContainerLab VM setup + resume service
#   config/instances.yaml                                — RHDP VM definitions (containerlab, control, vscode)
```

---

### Task 1: Initialize Git Repository and Scaffold Directory Structure

**Files:**
- Create: `.gitignore`
- Create: `CLAUDE.md`
- Create: directory structure (`containerlab/`, `playbooks/`, `rulebooks/`, `inventory/`, `validation/`, `lab-automation/`)

**Base reference:** The `zt-network-automation-workshop` repo at `/home/lgallego/Claude/zt-network-automation-workshop` provides patterns for AAP bootstrap, inventory, and ContainerLab setup. Review `lab-automation/playbooks/aap_bootstrap.yml` and `lab-automation/playbooks/tasks/controller_workshop_objects.yml` for the `ansible.controller` module patterns used in our AAP bootstrap task.

- [ ] **Step 1: Initialize git repository**

```bash
cd /home/lgallego/Claude/logicmonitor
git init
```

- [ ] **Step 2: Create .gitignore**

```
# Temporary files
tmp/

# Python
*.pyc
__pycache__/
.venv/

# Ansible
*.retry

# ContainerLab
clab-*/
.clab.yml.bak

# Secrets
*.vault
*vault*.yml
!*vault*.yml.example

# IDE
.vscode/
.idea/
```

- [ ] **Step 3: Create project CLAUDE.md**

```markdown
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
```

- [ ] **Step 4: Create directory structure**

```bash
mkdir -p containerlab playbooks rulebooks inventory/group_vars validation lab-automation
```

- [ ] **Step 5: Lint and commit**

```bash
git add .gitignore CLAUDE.md containerlab playbooks rulebooks inventory validation lab-automation
git commit -m "feat: initialize project structure for LM+AAP AIOps solution guide"
```

---

### Task 2: Define ContainerLab BGP Topology

**Files:**
- Create: `containerlab/bgp-topology.yml`

**Note:** We use `arista_ceos` kind (container EOS), NOT `veos` (vrnetlab VM-based EOS). The workshop documented MSR `0x345` QEMU crash failures with vEOS on nested KVM — cEOS avoids this entirely. The workshop's topology file lives on the containerlab VM at `~/1_multi_vendor_router/routers.clab.yml` (baked into the image, not in the repo). Our topology is version-controlled here.

- [ ] **Step 1: Write the ContainerLab topology file**

Three Arista cEOS routers in a triangle BGP mesh. Each router is its own AS (eBGP) with point-to-point links between them.

```yaml
---
name: lm-aiops-bgp

topology:
  kinds:
    arista_ceos:
      image: ceos:latest

  nodes:
    router1:
      kind: arista_ceos
      startup-config: |
        hostname router1
        !
        interface Ethernet1
          no switchport
          ip address 10.1.12.1/30
        !
        interface Ethernet2
          no switchport
          ip address 10.1.13.1/30
        !
        interface Loopback0
          ip address 1.1.1.1/32
        !
        router bgp 64501
          router-id 1.1.1.1
          neighbor 10.1.12.2 remote-as 64502
          neighbor 10.1.13.2 remote-as 64503
          network 1.1.1.1/32

    router2:
      kind: arista_ceos
      startup-config: |
        hostname router2
        !
        interface Ethernet1
          no switchport
          ip address 10.1.12.2/30
        !
        interface Ethernet2
          no switchport
          ip address 10.2.23.1/30
        !
        interface Loopback0
          ip address 2.2.2.2/32
        !
        router bgp 64502
          router-id 2.2.2.2
          neighbor 10.1.12.1 remote-as 64501
          neighbor 10.2.23.2 remote-as 64503
          network 2.2.2.2/32

    router3:
      kind: arista_ceos
      startup-config: |
        hostname router3
        !
        interface Ethernet1
          no switchport
          ip address 10.1.13.2/30
        !
        interface Ethernet2
          no switchport
          ip address 10.2.23.2/30
        !
        interface Loopback0
          ip address 3.3.3.3/32
        !
        router bgp 64503
          router-id 3.3.3.3
          neighbor 10.1.13.1 remote-as 64501
          neighbor 10.2.23.1 remote-as 64502
          network 3.3.3.3/32

  links:
    - endpoints: ["router1:eth1", "router2:eth1"]
    - endpoints: ["router1:eth2", "router3:eth1"]
    - endpoints: ["router2:eth2", "router3:eth2"]
```

- [ ] **Step 2: Commit**

```bash
git add containerlab/bgp-topology.yml
git commit -m "feat: add ContainerLab BGP mesh topology with 3 Arista cEOS routers"
```

---

### Task 3: Create Inventory for ContainerLab Devices

**Files:**
- Create: `inventory/hosts.yml`
- Create: `inventory/group_vars/arista.yml`

**Pattern reference:** The workshop at `zt-network-automation-workshop/network-workshop/lab_inventory/hosts` and `zt-network-automation-workshop/lab-automation/inventory/lab.yml` show two inventory patterns: direct ContainerLab names (for local runs from the clab VM) and LoadBalancer port-forwarding (for runs from AAP on the control VM). We provide both — the default `ansible_host` uses ContainerLab container names for local development, with comments showing the LB pattern for RHDP/AAP deployment.

- [ ] **Step 1: Write the inventory hosts file**

```yaml
---
# ContainerLab BGP mesh inventory
# Default: ansible_host uses clab container names (for local runs from the clab VM).
# For AAP/RHDP: override ansible_host to the LB/FIP hostname and use ansible_port
# per device (see commented example below), matching the pattern from
# zt-network-automation-workshop/lab-automation/inventory/lab.yml.
#
# RHDP LoadBalancer pattern (uncomment and set containerlab_fip):
#   ansible_host: "{{ containerlab_fip }}"
#   router1 ansible_port: 2222
#   router2 ansible_port: 2223
#   router3 ansible_port: 2224

all:
  children:
    arista:
      hosts:
        router1:
          ansible_host: clab-lm-aiops-bgp-router1
        router2:
          ansible_host: clab-lm-aiops-bgp-router2
        router3:
          ansible_host: clab-lm-aiops-bgp-router3
```

- [ ] **Step 2: Write the Arista group vars**

Following the workshop pattern from `zt-network-automation-workshop/network-workshop/lab_inventory/hosts` (`[arista:vars]` section):

```yaml
---
ansible_network_os: arista.eos.eos
ansible_connection: ansible.netcommon.network_cli
ansible_user: admin
ansible_password: admin
ansible_become: true
ansible_become_method: enable
```

- [ ] **Step 3: Commit**

```bash
git add inventory/
git commit -m "feat: add ContainerLab device inventory with Arista connection vars"
```

---

### Task 4: Write Crawl Stage — BGP Reset Playbook

**Files:**
- Create: `playbooks/reset_bgp_session.yml`
- Create: `playbooks/validate_bgp.yml`

- [ ] **Step 1: Write the BGP reset playbook**

This playbook receives `affected_host` and `alert_id` as extra vars from the EDA rulebook. It clears the BGP session on the affected device, then validates the peer re-establishes.

```yaml
---
- name: Reset BGP session on affected device
  hosts: "{{ affected_host }}"
  gather_facts: false

  tasks:
    - name: Gather current BGP summary
      arista.eos.eos_command:
        commands:
          - show ip bgp summary
      register: __bgp_before

    - name: Clear BGP sessions
      arista.eos.eos_command:
        commands:
          - clear ip bgp *

    - name: Wait for BGP peers to re-establish
      ansible.builtin.wait_for:
        timeout: 30

    - name: Validate BGP sessions re-established
      arista.eos.eos_command:
        commands:
          - show ip bgp summary
      register: __bgp_after

    - name: Assert BGP peers are established
      ansible.builtin.assert:
        that:
          - "'Established' in __bgp_after.stdout[0]"
        fail_msg: "BGP peers did not re-establish after reset"
        success_msg: "BGP peers successfully re-established"

    - name: Set remediation result for reporting
      ansible.builtin.set_stats:
        data:
          remediation_result: "bgp_reset_success"
          remediation_host: "{{ affected_host }}"
          alert_id: "{{ alert_id }}"
```

- [ ] **Step 2: Write the BGP validation playbook**

A standalone validation playbook reusable across stages.

```yaml
---
- name: Validate BGP state on device
  hosts: "{{ target_host | default('arista') }}"
  gather_facts: false

  tasks:
    - name: Gather BGP summary
      arista.eos.eos_command:
        commands:
          - show ip bgp summary
      register: __bgp_summary

    - name: Display BGP summary
      ansible.builtin.debug:
        var: __bgp_summary.stdout_lines[0]
        verbosity: 1

    - name: Assert all BGP peers are established
      ansible.builtin.assert:
        that:
          - "'Idle' not in __bgp_summary.stdout[0]"
          - "'Active' not in __bgp_summary.stdout[0]"
        fail_msg: "One or more BGP peers are not in Established state"
        success_msg: "All BGP peers are in Established state"
```

- [ ] **Step 3: Lint playbooks**

```bash
ansible-lint playbooks/reset_bgp_session.yml playbooks/validate_bgp.yml
```

- [ ] **Step 4: Commit**

```bash
git add playbooks/reset_bgp_session.yml playbooks/validate_bgp.yml
git commit -m "feat: add Crawl stage BGP reset and validation playbooks"
```

---

### Task 5: Write Crawl Stage — Incident Simulation Playbook

**Files:**
- Create: `playbooks/simulate_bgp_down.yml`

- [ ] **Step 1: Write the BGP down simulation playbook**

Shuts down an interface on a router to break BGP peering — simulating the incident that triggers the Crawl stage.

```yaml
---
- name: Simulate BGP peer down by shutting interface
  hosts: "{{ target_host | default('router2') }}"
  gather_facts: false

  vars:
    target_interface: "{{ interface | default('Ethernet1') }}"

  tasks:
    - name: Show BGP state before disruption
      arista.eos.eos_command:
        commands:
          - show ip bgp summary
      register: __bgp_before

    - name: Display BGP state before disruption
      ansible.builtin.debug:
        var: __bgp_before.stdout_lines[0]
        verbosity: 1

    - name: Shut down interface to break BGP peering
      arista.eos.eos_interfaces:
        config:
          - name: "{{ target_interface }}"
            enabled: false
        state: merged

    - name: Confirm interface is down
      arista.eos.eos_command:
        commands:
          - "show interfaces {{ target_interface }} status"
      register: __iface_status

    - name: Display post-disruption interface status
      ansible.builtin.debug:
        msg: >-
          Interface {{ target_interface }} shut down on {{ inventory_hostname }}.
          BGP peering should drop within hold-timer window.
        verbosity: 0
```

- [ ] **Step 2: Lint and commit**

```bash
ansible-lint playbooks/simulate_bgp_down.yml
git add playbooks/simulate_bgp_down.yml
git commit -m "feat: add Crawl incident simulation playbook (BGP down)"
```

---

### Task 6: Write EDA Rulebook — Crawl Rules

**Files:**
- Create: `rulebooks/logicmonitor_network.yml`

- [ ] **Step 1: Write the initial rulebook with Crawl-stage rules**

The rulebook condition fields (`event.payload.type`, `event.payload.host`, `event.payload.id`) use placeholder field names. These must be updated with actual LogicMonitor webhook payload field names once LM API access is available. `[REQUIRES LM ACCESS]`

```yaml
---
# LogicMonitor AIOps - Network Remediation Rulebook
# Tiered rules: Crawl (deterministic) → Walk (AI-enriched) → Run (agentic catch-all)
#
# LM webhook payload fields are placeholders until verified against live LM webhook.
# Update event.payload.* field names to match actual LM alert JSON structure.

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
```

- [ ] **Step 2: Lint and commit**

```bash
ansible-lint rulebooks/logicmonitor_network.yml
git add rulebooks/logicmonitor_network.yml
git commit -m "feat: add EDA rulebook with Crawl-stage BGP peer down rule"
```

---

### Task 7: Write Shared — Report Back to LogicMonitor Playbook

**Files:**
- Create: `playbooks/report_to_logicmonitor.yml`

- [ ] **Step 1: Write the LM reporting playbook**

This playbook acknowledges and annotates an alert in LogicMonitor after remediation. Uses `ansible.builtin.uri` to call the LM API directly. The API endpoint and payload structure are placeholders. `[REQUIRES LM ACCESS]`

```yaml
---
- name: Report remediation result to LogicMonitor
  hosts: localhost
  connection: local
  gather_facts: false

  vars:
    # These vars are passed from the calling workflow/job template
    # lm_company: "yourcompany"
    # lm_bearer_token: "{{ lookup('env', 'LM_BEARER_TOKEN') }}"
    # alert_id: ""
    # remediation_result: ""
    # remediation_host: ""

  tasks:
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
        status_code:
          - 200
          - 202
      register: __ack_result

    - name: Display acknowledgment result
      ansible.builtin.debug:
        var: __ack_result.status
        verbosity: 1
```

- [ ] **Step 2: Lint and commit**

```bash
ansible-lint playbooks/report_to_logicmonitor.yml
git add playbooks/report_to_logicmonitor.yml
git commit -m "feat: add LM alert acknowledgment playbook (placeholder API)"
```

---

### Task 8: Write Walk Stage — Edwin AI Enrichment Playbook

**Files:**
- Create: `playbooks/enrich_with_edwin_ai.yml`

- [ ] **Step 1: Write the Edwin AI enrichment playbook**

Queries Edwin AI for correlated alerts and insights on the affected device. Determines root cause and passes it as a workflow artifact via `set_stats`. The `query_api` response parsing is based on the module documentation — exact field names may need adjustment when tested against live Edwin AI. `[REQUIRES LM ACCESS]`

```yaml
---
- name: Enrich alert with Edwin AI context
  hosts: localhost
  connection: local
  gather_facts: false

  vars:
    # Passed from the workflow template via extra_vars
    # affected_host: ""
    # alert_id: ""
    # alert_context: {}
    # edwin_portal: ""
    # edwin_access_id: ""
    # edwin_access_key: ""
    edwin_lookback_window: 3600

  tasks:
    - name: Query Edwin AI for correlated alerts
      logicmonitor.edwin_ai.query_api:
        portal: "{{ edwin_portal }}"
        access_id: "{{ edwin_access_id }}"
        access_key: "{{ edwin_access_key }}"
        record_type: alerts
        limit: 20
        lookback_window: "{{ edwin_lookback_window }}"
      register: __edwin_alerts

    - name: Query Edwin AI for insights
      logicmonitor.edwin_ai.query_api:
        portal: "{{ edwin_portal }}"
        access_id: "{{ edwin_access_id }}"
        access_key: "{{ edwin_access_key }}"
        record_type: insights
        limit: 10
        lookback_window: "{{ edwin_lookback_window }}"
      register: __edwin_insights

    - name: Analyze correlated alerts for root cause
      ansible.builtin.set_fact:
        __correlated_alerts: "{{ __edwin_alerts.data.results | default([]) }}"
        __insights: "{{ __edwin_insights.data.results | default([]) }}"

    - name: Determine root cause from correlated context
      ansible.builtin.set_fact:
        __root_cause: >-
          {% set alert_types = __correlated_alerts | map(attribute='type', default='unknown') | list %}
          {% if 'interface_error' in alert_types %}
          interface_errors
          {% elif 'cpu_high' in alert_types or 'resource_exhaustion' in alert_types %}
          cpu_exhaustion
          {% elif 'config_change' in alert_types %}
          config_drift
          {% else %}
          unknown
          {% endif %}

    - name: Report enrichment results
      ansible.builtin.debug:
        msg: >-
          Edwin AI enrichment complete.
          Correlated alerts: {{ __correlated_alerts | length }}.
          Root cause determination: {{ __root_cause | trim }}.
        verbosity: 0

    - name: Set workflow artifacts for downstream nodes
      ansible.builtin.set_stats:
        data:
          root_cause: "{{ __root_cause | trim }}"
          correlated_alert_count: "{{ __correlated_alerts | length }}"
          affected_host: "{{ affected_host }}"
          alert_id: "{{ alert_id }}"
```

- [ ] **Step 2: Lint and commit**

```bash
ansible-lint playbooks/enrich_with_edwin_ai.yml
git add playbooks/enrich_with_edwin_ai.yml
git commit -m "feat: add Walk stage Edwin AI enrichment playbook"
```

---

### Task 9: Write Walk Stage — Remediation Branch Playbooks

**Files:**
- Create: `playbooks/bounce_interface.yml`
- Create: `playbooks/rollback_config.yml`

- [ ] **Step 1: Write the interface bounce playbook**

```yaml
---
- name: Bounce interface to resolve BGP flapping
  hosts: "{{ affected_host }}"
  gather_facts: false

  vars:
    target_interface: "{{ interface | default('Ethernet1') }}"

  tasks:
    - name: Shut down interface
      arista.eos.eos_interfaces:
        config:
          - name: "{{ target_interface }}"
            enabled: false
        state: merged

    - name: Wait for interface to fully go down
      ansible.builtin.wait_for:
        timeout: 5

    - name: Bring interface back up
      arista.eos.eos_interfaces:
        config:
          - name: "{{ target_interface }}"
            enabled: true
        state: merged

    - name: Wait for BGP to re-establish
      ansible.builtin.wait_for:
        timeout: 30

    - name: Validate BGP peers re-established
      arista.eos.eos_command:
        commands:
          - show ip bgp summary
      register: __bgp_after

    - name: Assert BGP peers are established
      ansible.builtin.assert:
        that:
          - "'Established' in __bgp_after.stdout[0]"
        fail_msg: "BGP peers did not re-establish after interface bounce"
        success_msg: "BGP peers re-established after interface bounce"

    - name: Set remediation result
      ansible.builtin.set_stats:
        data:
          remediation_result: "interface_bounce_success"
          remediation_host: "{{ affected_host }}"
          alert_id: "{{ alert_id }}"
```

- [ ] **Step 2: Write the config rollback playbook**

```yaml
---
- name: Rollback configuration to resolve BGP config drift
  hosts: "{{ affected_host }}"
  gather_facts: false

  tasks:
    - name: Get available configuration sessions
      arista.eos.eos_command:
        commands:
          - show configuration sessions
      register: __config_sessions

    - name: Rollback to last checkpoint
      arista.eos.eos_config:
        replace: config
        src: "startup-config"
        backup: true

    - name: Wait for BGP to re-converge after config rollback
      ansible.builtin.wait_for:
        timeout: 30

    - name: Validate BGP peers re-established
      arista.eos.eos_command:
        commands:
          - show ip bgp summary
      register: __bgp_after

    - name: Assert BGP peers are established
      ansible.builtin.assert:
        that:
          - "'Established' in __bgp_after.stdout[0]"
        fail_msg: "BGP peers did not re-establish after config rollback"
        success_msg: "BGP peers re-established after config rollback"

    - name: Set remediation result
      ansible.builtin.set_stats:
        data:
          remediation_result: "config_rollback_success"
          remediation_host: "{{ affected_host }}"
          alert_id: "{{ alert_id }}"
```

- [ ] **Step 3: Lint and commit**

```bash
ansible-lint playbooks/bounce_interface.yml playbooks/rollback_config.yml
git add playbooks/bounce_interface.yml playbooks/rollback_config.yml
git commit -m "feat: add Walk stage remediation branch playbooks (bounce, rollback)"
```

---

### Task 10: Write Walk Stage — Incident Simulation Playbooks

**Files:**
- Create: `playbooks/simulate_interface_errors.yml`
- Create: `playbooks/simulate_config_drift.yml`

- [ ] **Step 1: Write the interface errors simulation**

Rapidly toggles an interface to create flapping + error counters that LM and Edwin AI would correlate.

```yaml
---
- name: Simulate interface errors causing BGP flapping
  hosts: "{{ target_host | default('router2') }}"
  gather_facts: false

  vars:
    target_interface: "{{ interface | default('Ethernet1') }}"
    flap_count: "{{ flaps | default(3) }}"

  tasks:
    - name: Display simulation parameters
      ansible.builtin.debug:
        msg: >-
          Simulating interface flapping on {{ target_interface }}
          ({{ flap_count }} flaps) to trigger BGP instability
          with correlated interface error alerts in LM.
        verbosity: 0

    - name: Flap interface to generate errors and BGP instability
      arista.eos.eos_interfaces:
        config:
          - name: "{{ target_interface }}"
            enabled: "{{ item == 'up' }}"
        state: merged
      loop: "{{ ['down', 'up'] * (flap_count | int) }}"
      loop_control:
        pause: 3
```

- [ ] **Step 2: Write the config drift simulation**

Changes a BGP neighbor's AS number to cause a peering mismatch — Edwin AI should correlate the config change event with the resulting BGP failure.

```yaml
---
- name: Simulate BGP config drift
  hosts: "{{ target_host | default('router2') }}"
  gather_facts: false

  tasks:
    - name: Display simulation intent
      ansible.builtin.debug:
        msg: >-
          Introducing BGP configuration drift on {{ inventory_hostname }}.
          Changing neighbor AS to cause peering mismatch.
          Edwin AI should correlate config change event with BGP failure.
        verbosity: 0

    - name: Introduce wrong AS number for a BGP neighbor
      arista.eos.eos_bgp_global:
        config:
          as_number: "64502"
          neighbor:
            - neighbor_address: 10.1.12.1
              remote_as: 99999
        state: replaced
```

- [ ] **Step 3: Lint and commit**

```bash
ansible-lint playbooks/simulate_interface_errors.yml playbooks/simulate_config_drift.yml
git add playbooks/simulate_interface_errors.yml playbooks/simulate_config_drift.yml
git commit -m "feat: add Walk incident simulation playbooks (interface errors, config drift)"
```

---

### Task 11: Update EDA Rulebook — Add Walk and Run Rules

**Files:**
- Modify: `rulebooks/logicmonitor_network.yml`

- [ ] **Step 1: Add Walk and Run rules to the rulebook**

Replace the full file content with the complete tiered rulebook:

```yaml
---
# LogicMonitor AIOps - Network Remediation Rulebook
# Tiered rules: Crawl (deterministic) → Walk (AI-enriched) → Run (agentic catch-all)
#
# Rules are evaluated in order, most specific first.
# LM webhook payload fields are placeholders until verified against live LM webhook.
# Update event.payload.* field names to match actual LM alert JSON structure.

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

- [ ] **Step 2: Lint and commit**

```bash
ansible-lint rulebooks/logicmonitor_network.yml
git add rulebooks/logicmonitor_network.yml
git commit -m "feat: add Walk and Run rules to EDA rulebook (tiered crawl-walk-run)"
```

---

### Task 12: Write Run Stage — Edwin AI Escalation Playbook

**Files:**
- Create: `playbooks/escalate_to_edwin_ai.yml`

- [ ] **Step 1: Write the escalation playbook**

Receives the raw unmatched alert from EDA and sends it to Edwin AI for investigation. The mechanism for notifying Edwin AI is a placeholder — this depends on how Edwin AI accepts inbound investigation requests (API call, webhook, or queue). `[REQUIRES LM ACCESS]`

```yaml
---
- name: Escalate unmatched alert to Edwin AI for investigation
  hosts: localhost
  connection: local
  gather_facts: false

  vars:
    # Passed from the EDA catch-all rule
    # raw_alert: {}
    # source: "eda_catch_all"
    # edwin_portal: ""
    # edwin_access_id: ""
    # edwin_access_key: ""

  tasks:
    - name: Log escalation event
      ansible.builtin.debug:
        msg: >-
          Escalating unmatched alert to Edwin AI.
          Alert type: {{ raw_alert.type | default('unknown') }}.
          Source: {{ source }}.
          No matching EDA rule found — Edwin AI will investigate
          and recommend remediation via AAP MCP Server.
        verbosity: 0

    - name: Query Edwin AI for context on the unmatched alert
      logicmonitor.edwin_ai.query_api:
        portal: "{{ edwin_portal }}"
        access_id: "{{ edwin_access_id }}"
        access_key: "{{ edwin_access_key }}"
        record_type: insights
        limit: 10
        lookback_window: 3600
      register: __edwin_insights

    - name: Prepare alert context for Edwin AI agent
      ansible.builtin.set_fact:
        __escalation_payload:
          alert: "{{ raw_alert }}"
          source: "{{ source }}"
          edwin_insights: "{{ __edwin_insights.data.results | default([]) }}"
          timestamp: "{{ ansible_date_time.iso8601 | default(now()) }}"

    - name: Send escalation to Edwin AI agent endpoint
      ansible.builtin.uri:
        url: "https://{{ edwin_portal }}.dexda.ai/api/escalation"
        method: POST
        headers:
          Authorization: "Bearer {{ edwin_access_key }}"
          Content-Type: "application/json"
        body_format: json
        body: "{{ __escalation_payload }}"
        status_code:
          - 200
          - 202
      register: __escalation_result
      ignore_errors: true

    - name: Report escalation outcome
      ansible.builtin.debug:
        msg: >-
          Edwin AI escalation {{ 'succeeded' if not __escalation_result.failed else 'failed' }}.
          Edwin AI will connect to AAP MCP Server to discover
          and recommend remediation actions.
        verbosity: 0
```

- [ ] **Step 2: Lint and commit**

```bash
ansible-lint playbooks/escalate_to_edwin_ai.yml
git add playbooks/escalate_to_edwin_ai.yml
git commit -m "feat: add Run stage Edwin AI escalation playbook"
```

---

### Task 13: Write Run Stage — Unknown Alert Simulation

**Files:**
- Create: `playbooks/simulate_unknown_alert.yml`

- [ ] **Step 1: Write the unknown alert simulation playbook**

Sends a novel alert type directly to the EDA webhook endpoint via `ansible.builtin.uri`, simulating an LM alert that won't match any Crawl or Walk rule.

```yaml
---
- name: Simulate unknown alert to trigger Run-stage escalation
  hosts: localhost
  connection: local
  gather_facts: false

  vars:
    eda_webhook_url: "{{ eda_url | default('http://localhost:5000/logicmonitor') }}"

  tasks:
    - name: Send unmatched alert to EDA webhook
      ansible.builtin.uri:
        url: "{{ eda_webhook_url }}"
        method: POST
        headers:
          Content-Type: "application/json"
        body_format: json
        body:
          type: "network_anomaly_unknown"
          severity: "critical"
          host: "router1"
          id: "SIM-RUN-001"
          message: >-
            Unusual network degradation pattern detected across
            multiple interfaces. No matching remediation rule exists.
          details:
            affected_interfaces:
              - Ethernet1
              - Ethernet2
            anomaly_score: 0.92
            first_seen: "{{ ansible_date_time.iso8601 | default(now()) }}"
        status_code:
          - 200
          - 202
      register: __webhook_result

    - name: Confirm alert sent to EDA
      ansible.builtin.debug:
        msg: >-
          Unknown alert sent to EDA webhook.
          Response: {{ __webhook_result.status }}.
          This should trigger the catch-all rule and escalate to Edwin AI.
        verbosity: 0
```

- [ ] **Step 2: Lint and commit**

```bash
ansible-lint playbooks/simulate_unknown_alert.yml
git add playbooks/simulate_unknown_alert.yml
git commit -m "feat: add Run stage unknown alert simulation playbook"
```

---

### Task 14: Write Validation Scripts

**Files:**
- Create: `validation/test_crawl.sh`
- Create: `validation/test_walk.sh`
- Create: `validation/test_run.sh`

- [ ] **Step 1: Write the Crawl validation script**

```bash
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
```

- [ ] **Step 2: Write the Walk validation script**

```bash
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
```

- [ ] **Step 3: Write the Run validation script**

```bash
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
```

- [ ] **Step 4: Make scripts executable and commit**

```bash
chmod +x validation/test_crawl.sh validation/test_walk.sh validation/test_run.sh
git add validation/
git commit -m "feat: add per-stage validation scripts (curl-based webhook tests)"
```

---

### Task 15: Write AAP Bootstrap Playbook for LM AIOps Objects

**Files:**
- Create: `lab-automation/aap_bootstrap_lm_aiops.yml`

**Pattern reference:** Adapted from `zt-network-automation-workshop/lab-automation/playbooks/tasks/controller_workshop_objects.yml` which creates organizations, inventories, credentials, job templates, and RBAC using `ansible.controller` modules. Our bootstrap creates the LM-specific Controller objects needed for the three maturity stages.

- [ ] **Step 1: Write the AAP bootstrap playbook**

This playbook provisions all AAP Controller objects needed for the LM AIOps demo. It assumes the base workshop bootstrap has already run (default org, credentials, network inventory exist). It creates LM-specific job templates, workflow templates, and credentials.

```yaml
---
# Bootstrap AAP Controller with LM AIOps demo objects.
# Assumes base workshop bootstrap has run (default org, network inventory, EE exist).
# Pattern adapted from zt-network-automation-workshop/lab-automation/playbooks/tasks/controller_workshop_objects.yml

- name: Bootstrap AAP Controller for LM AIOps demo
  hosts: localhost
  connection: local
  gather_facts: false

  vars:
    controller_host: "{{ lookup('ansible.builtin.env', 'CONTROLLER_HOST') | default('https://localhost', true) }}"
    controller_username: "{{ lookup('ansible.builtin.env', 'CONTROLLER_USERNAME') | default('admin', true) }}"
    controller_password: "{{ lookup('ansible.builtin.env', 'CONTROLLER_PASSWORD') | default('ansible123!', true) }}"
    controller_verify_ssl: false

    lm_aiops_org: "Network Ops"
    lm_aiops_project_name: "LM AIOps Solution Guide"
    lm_aiops_project_url: ""
    lm_aiops_inventory: "BGP Lab Inventory"
    lm_aiops_credential: "Workshop Credential"
    lm_aiops_ee: "Default execution environment"

  tasks:
    # --- Organization ---
    - name: Ensure Network Ops organization exists
      ansible.controller.organization:
        name: "{{ lm_aiops_org }}"
        description: "Network Operations — LM AIOps demo"
        state: present
        controller_host: "{{ controller_host }}"
        controller_username: "{{ controller_username }}"
        controller_password: "{{ controller_password }}"
        validate_certs: "{{ controller_verify_ssl }}"

    # --- LM API Credential (custom credential type) ---
    - name: Create LM API credential type
      ansible.controller.credential_type:
        name: "LogicMonitor API"
        kind: cloud
        inputs:
          fields:
            - id: lm_company
              label: "LM Company Name"
              type: string
            - id: lm_bearer_token
              label: "LM Bearer Token"
              type: string
              secret: true
          required:
            - lm_company
            - lm_bearer_token
        injectors:
          extra_vars:
            lm_company: "{{'{{' }} lm_company {{ '}}' }}"
            lm_bearer_token: "{{'{{' }} lm_bearer_token {{ '}}' }}"
        state: present
        controller_host: "{{ controller_host }}"
        controller_username: "{{ controller_username }}"
        controller_password: "{{ controller_password }}"
        validate_certs: "{{ controller_verify_ssl }}"

    # --- Edwin AI Credential (custom credential type) ---
    - name: Create Edwin AI credential type
      ansible.controller.credential_type:
        name: "Edwin AI API"
        kind: cloud
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
          required:
            - edwin_portal
            - edwin_access_id
            - edwin_access_key
        injectors:
          extra_vars:
            edwin_portal: "{{'{{' }} edwin_portal {{ '}}' }}"
            edwin_access_id: "{{'{{' }} edwin_access_id {{ '}}' }}"
            edwin_access_key: "{{'{{' }} edwin_access_key {{ '}}' }}"
        state: present
        controller_host: "{{ controller_host }}"
        controller_username: "{{ controller_username }}"
        controller_password: "{{ controller_password }}"
        validate_certs: "{{ controller_verify_ssl }}"

    # --- CRAWL: Job Template ---
    - name: "Job template — Reset BGP Session (Crawl)"
      ansible.controller.job_template:
        name: "Reset BGP Session"
        job_type: run
        organization: "{{ lm_aiops_org }}"
        project: "{{ lm_aiops_project_name }}"
        playbook: "playbooks/reset_bgp_session.yml"
        inventory: "{{ lm_aiops_inventory }}"
        credentials:
          - "{{ lm_aiops_credential }}"
        ask_variables_on_launch: true
        state: present
        controller_host: "{{ controller_host }}"
        controller_username: "{{ controller_username }}"
        controller_password: "{{ controller_password }}"
        validate_certs: "{{ controller_verify_ssl }}"

    # --- WALK: Workflow Template ---
    # Individual job templates for workflow nodes
    - name: "Job template — Enrich with Edwin AI (Walk)"
      ansible.controller.job_template:
        name: "Enrich with Edwin AI"
        job_type: run
        organization: "{{ lm_aiops_org }}"
        project: "{{ lm_aiops_project_name }}"
        playbook: "playbooks/enrich_with_edwin_ai.yml"
        inventory: "{{ lm_aiops_inventory }}"
        credentials:
          - "{{ lm_aiops_credential }}"
        ask_variables_on_launch: true
        state: present
        controller_host: "{{ controller_host }}"
        controller_username: "{{ controller_username }}"
        controller_password: "{{ controller_password }}"
        validate_certs: "{{ controller_verify_ssl }}"

    - name: "Job template — Bounce Interface (Walk)"
      ansible.controller.job_template:
        name: "Bounce Interface"
        job_type: run
        organization: "{{ lm_aiops_org }}"
        project: "{{ lm_aiops_project_name }}"
        playbook: "playbooks/bounce_interface.yml"
        inventory: "{{ lm_aiops_inventory }}"
        credentials:
          - "{{ lm_aiops_credential }}"
        ask_variables_on_launch: true
        state: present
        controller_host: "{{ controller_host }}"
        controller_username: "{{ controller_username }}"
        controller_password: "{{ controller_password }}"
        validate_certs: "{{ controller_verify_ssl }}"

    - name: "Job template — Rollback Config (Walk)"
      ansible.controller.job_template:
        name: "Rollback Config"
        job_type: run
        organization: "{{ lm_aiops_org }}"
        project: "{{ lm_aiops_project_name }}"
        playbook: "playbooks/rollback_config.yml"
        inventory: "{{ lm_aiops_inventory }}"
        credentials:
          - "{{ lm_aiops_credential }}"
        ask_variables_on_launch: true
        state: present
        controller_host: "{{ controller_host }}"
        controller_username: "{{ controller_username }}"
        controller_password: "{{ controller_password }}"
        validate_certs: "{{ controller_verify_ssl }}"

    # --- RUN: Job Template ---
    - name: "Job template — Escalate to Edwin AI (Run)"
      ansible.controller.job_template:
        name: "Escalate to Edwin AI"
        job_type: run
        organization: "{{ lm_aiops_org }}"
        project: "{{ lm_aiops_project_name }}"
        playbook: "playbooks/escalate_to_edwin_ai.yml"
        inventory: "{{ lm_aiops_inventory }}"
        credentials:
          - "{{ lm_aiops_credential }}"
        ask_variables_on_launch: true
        state: present
        controller_host: "{{ controller_host }}"
        controller_username: "{{ controller_username }}"
        controller_password: "{{ controller_password }}"
        validate_certs: "{{ controller_verify_ssl }}"

    # --- Shared: Report to LM ---
    - name: "Job template — Report to LogicMonitor"
      ansible.controller.job_template:
        name: "Report to LogicMonitor"
        job_type: run
        organization: "{{ lm_aiops_org }}"
        project: "{{ lm_aiops_project_name }}"
        playbook: "playbooks/report_to_logicmonitor.yml"
        inventory: "{{ lm_aiops_inventory }}"
        credentials:
          - "{{ lm_aiops_credential }}"
        ask_variables_on_launch: true
        state: present
        controller_host: "{{ controller_host }}"
        controller_username: "{{ controller_username }}"
        controller_password: "{{ controller_password }}"
        validate_certs: "{{ controller_verify_ssl }}"
```

Note: The workflow template "BGP Smart Remediation" (Walk stage) should be created via the Controller UI or the `ansible.controller.workflow_job_template` and `ansible.controller.workflow_job_template_node` modules. The workflow connects: Enrich with Edwin AI → (branch on root_cause artifact) → Bounce Interface OR Rollback Config → Report to LogicMonitor. Workflow node wiring is complex in code and easier to demonstrate via the UI in the solution guide walkthrough.

- [ ] **Step 2: Lint and commit**

```bash
ansible-lint lab-automation/aap_bootstrap_lm_aiops.yml
git add lab-automation/aap_bootstrap_lm_aiops.yml
git commit -m "feat: add AAP bootstrap playbook for LM AIOps Controller objects"
```

---

### Task 16: Write the Solution Guide Document

**Files:**
- Create: `README-AIOps-LogicMonitor.md`

This is the main deliverable — the full solution guide. It follows the ansible-tmm template structure from the spec (sections 1-12). This is a large content document (~3000-4000 words).

- [ ] **Step 1: Write sections 1-5 (Overview through Architecture)**

Write the front matter of the solution guide: Overview (hero + value prop), Background (AIOps gap, LM/Edwin AI, AAP), Solution (components table, personas), Prerequisites, and Integration Architecture (diagrams, value chain, surfaces table).

Reference the spec document at `docs/superpowers/specs/2026-05-21-logicmonitor-aiops-solution-guide-design.md` for the architecture diagrams and value chain mapping — transplant them into the guide with appropriate framing text for the customer audience.

- [ ] **Step 2: Write sections 6-8 (Crawl, Walk, Run stages)**

Write the three stage walkthroughs. Each stage includes: per-stage architecture diagram, setup instructions (LM webhook config, EDA rulebook, job/workflow templates), use case walkthrough with the demo scenario, incident simulation instructions, and validation steps.

For each stage, reference the actual playbook and rulebook files from this repo with inline YAML snippets. Use the flow diagrams from the spec.

- [ ] **Step 3: Write sections 9-12 (Validation, Maturity, ROI, Sources)**

Write the closing sections: consolidated validation/troubleshooting table, maturity path summary (crawl→walk→run visual + promotion pattern), ROI recap (MTTR, alert noise, governance metrics), and Sources/Next Steps with links to all repos, collections, and documentation.

- [ ] **Step 4: Lint markdown and commit**

```bash
# Verify no broken links or formatting issues
head -50 README-AIOps-LogicMonitor.md
git add README-AIOps-LogicMonitor.md
git commit -m "feat: add LogicMonitor AIOps solution guide (crawl-walk-run)"
```

---

### Task 17: Final Review and Cleanup

- [ ] **Step 1: Verify all files are committed**

```bash
git status
git log --oneline
```

- [ ] **Step 2: Run ansible-lint on all playbooks and rulebooks**

```bash
ansible-lint playbooks/ rulebooks/
```

- [ ] **Step 3: Verify file structure matches the plan**

```bash
find . -type f -not -path './.git/*' -not -path './collections/*' -not -path './tmp/*' | sort
```

- [ ] **Step 4: Review open questions and flag remaining work**

Check the five open questions from the spec:
1. LM webhook payload structure — update rulebook conditions when access available
2. Edwin AI response structure — update enrichment playbook parsing when access available
3. Edwin AI → MCP connectivity — verify escalation flow when access available
4. ContainerLab + LM monitoring — verify LM can monitor cEOS containers
5. Simulation fidelity — test simulations against live LM/Edwin AI

- [ ] **Step 5: Final commit with any cleanup**

```bash
git add -A
git status
# Only commit if there are changes
git diff --cached --stat && git commit -m "chore: final cleanup and review"
```

---

## Future Enhancements (Out of Scope for Initial Implementation)

### NetBox WAN Circuit Failover Integration

The `summit-netbox-circuits-demo` (local copy at `/home/lgallego/Claude/summit-netbox-circuits-demo`) is a Summit demo showing automated WAN circuit failover using NetBox as source of truth + EDA + AAP 2.6. It could be integrated as an additional use case or "Going Further" section in the solution guide.

**Integration possibilities:**

1. **LM monitors circuit health** — LM detects latency/packet-loss on WAN circuits, triggers failover via EDA before full outage occurs
2. **Edwin AI enrichment for circuit decisions** — Edwin AI correlates circuit alerts with other infrastructure events to determine if failover is the right action
3. **NetBox as shared CMDB** — Both LM and AAP reference NetBox for network topology; LM alert includes circuit ID that the existing failover playbook handles
4. **Combined reporting** — Incident reports enriched with LM metrics (latency graphs, packet loss) alongside NetBox topology and failover details
5. **Post-failover verification via LM** — After failover, query LM to confirm backup circuit health metrics are within thresholds

**Reusable patterns from the NetBox demo:**

- Idempotent AAP bootstrap playbook (`pb_setup_aap.yml`) — similar to our `aap_bootstrap_lm_aiops.yml`
- EDA rulebook structure — clean webhook → condition → `run_workflow_template` action
- Dynamic discovery from CMDB — no hardcoded IPs, all derived from NetBox queries
- HTML incident report generation with Jinja2 templates
- GitHub Pages report publishing (no infrastructure needed)

See `resources/reference.md` section "Future Enhancement: NetBox Circuits Demo" for full details.
