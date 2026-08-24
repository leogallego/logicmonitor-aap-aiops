# LogicMonitor + AAP AIOps: Demo Guide

This is the hands-on companion to the [Solution Guide](README-AIOps-LogicMonitor.md). It walks through setting up a lab environment with ContainerLab and Arista cEOS routers, then running the demo for each maturity stage: Crawl, Walk, and Run.

---

## Contents

- [Prerequisites](#prerequisites)
- [Part 1: Lab Environment Setup](#part-1-lab-environment-setup)
- [Part 2: Crawl Stage Demo](#part-2-crawl-stage-demo)
- [Part 3: Walk Stage Demo](#part-3-walk-stage-demo)
- [Part 4: Run Stage Demo](#part-4-run-stage-demo)
- [Part 5: Cleanup](#part-5-cleanup)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

| Requirement | Details |
|-------------|---------|
| ContainerLab | Latest version ([install docs](https://containerlab.dev/install/)) |
| Arista cEOS image | `ceos:latest` -- requires an [Arista account](https://www.arista.com/en/login) to download |
| Docker | Running and accessible by ContainerLab |
| AAP 2.6 | Automation Controller + EDA Controller |
| LogicMonitor | Active account with API access |
| Edwin AI | Portal with API credentials (`access_id`, `access_key`) |
| Ansible collections | `arista.eos`, `logicmonitor.integration`, `logicmonitor.edwin_ai`, `ansible.eda`, `ansible.controller` |

---

## Part 1: Lab Environment Setup

### 1.1 Deploy the ContainerLab Topology

The lab uses a three-router eBGP mesh defined in `containerlab/bgp-topology.yml`:

```
              router1
             (AS 64501)
            /          \
     Eth1 /            \ Eth2
         /              \
    router2 ----Eth2---- router3
   (AS 64502)          (AS 64503)
```

Each router runs Arista cEOS with pre-configured BGP neighbors and loopback addresses.

Deploy the topology:

```bash
sudo containerlab deploy -t containerlab/bgp-topology.yml
```

Expected output:

```
INFO[0000] Containerlab v<version> started
INFO[0000] Parsing & checking topology file: bgp-topology.yml
INFO[0001] Creating lab directory: /home/<user>/clab-lm-aiops-bgp
INFO[0002] Creating container: "router1"
INFO[0002] Creating container: "router2"
INFO[0002] Creating container: "router3"
INFO[0005] Adding containerlab host entries to /etc/hosts file
INFO[0010] 🎉 New calculation for lm-aiops-bgp -> 3 nodes created
```

### 1.2 Verify Routers Are Running

```bash
sudo containerlab inspect -t containerlab/bgp-topology.yml
```

All three nodes should show `running` status.

### 1.3 Verify BGP Peering Is Established

SSH into any router and check BGP state:

```bash
ssh admin@clab-lm-aiops-bgp-router1
```

Password: `admin`

```
router1> enable
router1# show ip bgp summary
```

All neighbors should show `Estab` (EOS summary abbreviation; some views print `Established`). Repeat for `router2` and `router3` to confirm full-mesh peering.

Alternatively, use the validation playbook:

```bash
ansible-playbook playbooks/validate_bgp.yml -i inventory/hosts.yml
```

This asserts that no BGP peers are in `Idle` or `Active` state.

### 1.4 Configure the AAP Inventory

The inventory at `inventory/hosts.yml` uses ContainerLab container names as `ansible_host` values:

| Router | Container Name | AS Number |
|--------|---------------|-----------|
| router1 | `clab-lm-aiops-bgp-router1` | 64501 |
| router2 | `clab-lm-aiops-bgp-router2` | 64502 |
| router3 | `clab-lm-aiops-bgp-router3` | 64503 |

Connection settings are in `inventory/group_vars/arista.yml`:
- `ansible_network_os: arista.eos.eos`
- `ansible_connection: ansible.netcommon.network_cli`
- `ansible_user: admin` / `ansible_password: admin`

If AAP is running on a different host from ContainerLab, update `ansible_host` to match the resolvable hostname or IP for each container. See the comments in `inventory/hosts.yml` for the RHDP/LoadBalancer pattern with per-device ports.

### 1.5 Run the AAP Bootstrap

Controller connection comes from extra vars first, then environment. The playbook does **not** ship a default password.

**Option A — environment (credential types + job templates only):**

```bash
export CONTROLLER_HOST="https://<your-aap-controller>"
export CONTROLLER_USERNAME="admin"
export CONTROLLER_PASSWORD="<your-password>"
export LM_AIOPS_PROJECT_URL="https://github.com/<you>/logicmonitor-aap-aiops.git"
export WORKSHOP_SSH_PASSWORD="<lab-eos-ssh-password>"
# optional: export CONTROLLER_VERIFY_SSL=true

ansible-playbook lab-automation/aap_bootstrap_lm_aiops.yml
```

**Option B — vars file (same objects, values in one place):**

```bash
cp lab-automation/credentials.yml.example lab-automation/credentials.yml
# edit credentials.yml; it is gitignored — do not commit it
# required: controller_*, lm_aiops_project_url, workshop_ssh_password

ansible-playbook lab-automation/aap_bootstrap_lm_aiops.yml \
  -e @lab-automation/credentials.yml
```

Basic bootstrap now also creates the Controller project, Network Inventory
(lab hosts), Workshop Credential, and attaches `lm_aiops_ee` (default:
Default execution environment — that EE must already exist).

**Full bootstrap** also creates LM/Edwin credentials, the Event Stream, EDA
project, rulebook activation, and the Walk workflow. Set
`eda_controller_token_name` to an EDA token that can launch job templates.

```bash
ansible-playbook lab-automation/aap_bootstrap_lm_aiops.yml \
  -e @lab-automation/credentials.yml \
  -e full_bootstrap=true
```

Basic bootstrap creates:

| Object | Name | Stage |
|--------|------|-------|
| Organization | Network Ops | All |
| Project | LM AIOps Solution Guide | All |
| Inventory | Network Inventory | All |
| Credential | Workshop Credential | All |
| Credential Type | LogicMonitor API | All |
| Credential Type | Edwin AI API | Walk, Run |
| Job Template | Reset BGP Session | Crawl |
| Job Template | Enrich with Edwin AI | Walk |
| Job Template | Bounce Interface | Walk |
| Job Template | Restart Routing | Walk |
| Job Template | Rollback Config | Walk |
| Job Template | Escalate to Edwin AI | Run |
| Job Template | Report to LogicMonitor | All |

After a **basic** bootstrap, create these in the UI (skip if you used `full_bootstrap=true`):

- **LM API credential** using the "LogicMonitor API" credential type with your company name and bearer token
- **Edwin AI credential** using the "Edwin AI API" credential type with your portal, access ID, and access key. After creating the credential, attach it to the **"Enrich with Edwin AI"** and **"Escalate to Edwin AI"** job templates (these templates need both the Workshop Credential and the Edwin AI credential)
- **"BGP Smart Remediation" workflow template** with the node topology described in the [Solution Guide](README-AIOps-LogicMonitor.md#stage-2----walk-ai-enriched-remediation)

### 1.6 Create the EDA Event Stream

Skip this section if you already ran with `full_bootstrap=true` (the playbook creates "LogicMonitor Alerts").

In the EDA Controller UI:

1. Navigate to **Event Streams** and click **Create Event Stream**
2. Configure:

| Field | Value |
|-------|-------|
| Name | LogicMonitor Alerts |
| Credential type | Token (live LM Custom HTTP) or HMAC (synthetic `validation/test_*.sh` posts) |
| Organization | Network Ops |

3. Save and copy the **Event Stream URL**. For Token streams, copy the token/header value to add as a static header on the LM integration. For HMAC streams, copy the secret for `EDA_HMAC_SECRET` on synthetic tests -- Custom HTTP Delivery cannot HMAC-sign the body.

The Event Stream provides a platform-managed endpoint. AAP handles TLS, event routing, and credential validation. Live LM payloads must still match the `type` / `host` / `id` contract in the next step.

### 1.7 Configure LogicMonitor Webhook

LogicMonitor's native `##ALERTTYPE##` token is `alert` / `eventAlert` / similar -- it will **not** match the rulebook. Use the Custom HTTP templates in `lab-automation/lm-webhook/` so the JSON body uses the demo schema (`type`, `host`, `id`).

Create **three** Custom HTTP Delivery integrations (Settings → Integrations → Add):

| Stage | Template file | Hardcoded `type` | Assign to |
|-------|---------------|------------------|-----------|
| Crawl | `lab-automation/lm-webhook/crawl-bgp-peer-down.json` | `bgp_peer_down` | BGP peer down alert rule |
| Walk | `lab-automation/lm-webhook/walk-bgp-flapping.json` | `bgp_flapping` | BGP flapping / instability rule |
| Run | `lab-automation/lm-webhook/run-unmatched.json` | `network_anomaly_unknown` | A test or unmatched alert rule |

For each integration:

- **URL:** The Event Stream URL from step 1.6 (not `http://<eda-controller>:5000/logicmonitor`)
- **Method:** POST
- **Content-Type:** `application/json`
- **Alert Data:** Raw JSON -- paste the template file
- Name LM devices `router1` / `router2` / `router3` so `##HOST##` matches `inventory/hosts.yml`

Custom HTTP Delivery does **not** compute `X-Hub-Signature-256`. For live LM traffic, use an Event Stream credential type that a static header can satisfy (Token), or a signing proxy. HMAC in `validation/test_*.sh` applies only when `EDA_HMAC_SECRET` is set on synthetic posts. Full payload notes: `lab-automation/lm-webhook/README.md`.

> **Standalone testing:** For local development without Event Streams, POST the same JSON schema directly to `http://<eda-controller>:5000/logicmonitor`. The `ansible.eda.webhook` source in the rulebook listens on this endpoint independently. Set `EDA_WEBHOOK_URL` when running `validation/test_*.sh` against an Event Stream URL.

### 1.8 Deploy the EDA Rulebook Activation

Create a rulebook activation in the EDA Controller using `rulebooks/logicmonitor_network.yml`:

1. Select the rulebook and create an activation
2. Under **Event Stream mapping**, map the "LogicMonitor Alerts" Event Stream to the `ansible.eda.webhook` source defined in the rulebook
3. Activate

AAP replaces the webhook source plugin with its internal event delivery at activation time. The rulebook contains three rules evaluated in order:

1. `bgp_peer_down` -- triggers "Reset BGP Session" (Crawl)
2. `bgp_flapping` -- triggers "BGP Smart Remediation" workflow (Walk)
3. Catch-all -- triggers "Escalate to Edwin AI" (Run)

> **Note on debug output:** Demo and simulation playbooks use `verbosity: 0` on debug tasks so that enrichment results, escalation context, and simulation parameters are always visible in the job output. In production roles, set `verbosity: 1` or higher to suppress debug output at default verbosity.

---

## Part 2: Crawl Stage Demo

**Goal:** Demonstrate deterministic, event-driven remediation of a known BGP alert.

### 2.1 Verify BGP Is Healthy

```bash
ansible-playbook playbooks/validate_bgp.yml -i inventory/hosts.yml
```

Expected output:

```
TASK [Assert all BGP peers are established] ************************************
ok: [router1] => {
    "msg": "All BGP peers are in Established state"
}
ok: [router2] => {
    "msg": "All BGP peers are in Established state"
}
ok: [router3] => {
    "msg": "All BGP peers are in Established state"
}
```

### 2.2 Simulate the Incident

Shut down an interface on `router2` to break BGP peering with `router1`:

```bash
ansible-playbook playbooks/simulate_bgp_down.yml -i inventory/hosts.yml
```

This runs against `router2` by default and **leaves** `Ethernet1` shut (the link to `router1`). Restore tasks are tagged `never` / `restore`, so they do not run unless you pass `--tags restore`. The BGP session between `router2` (AS 64502) and `router1` (AS 64501) stays down until Crawl remediation (or a manual restore).

### 2.3 Observe the End-to-End Flow

1. **LogicMonitor** detects the BGP peer down and fires a critical alert
2. **LM webhook** delivers the alert to the EDA Event Stream
3. **EDA rulebook** matches `event.payload.type == "bgp_peer_down"` (Crawl rule)
4. **EDA** triggers the "Reset BGP Session" job template in AAP Controller
5. **AAP** runs `playbooks/reset_bgp_session.yml` targeting `router2`
6. The playbook enables `Ethernet1` (the lab-induced shut), clears BGP sessions, and waits for `Estab` in `show ip bgp summary`
7. BGP re-establishes between `router2` and `router1`
8. AAP reports the remediation result back to LogicMonitor (alert acknowledged)

### 2.4 Run the Validation Script

```bash
bash validation/test_crawl.sh
```

This POSTs the same JSON schema as `lab-automation/lm-webhook/crawl-bgp-peer-down.json` (synthetic `type` / `host` / `id`). It does not wait for a live LogicMonitor alert. Override the target with `EDA_WEBHOOK_URL` (and `EDA_HMAC_SECRET` if the Event Stream requires HMAC):

```
=== Crawl Stage Validation ===
Sending BGP peer down alert to EDA...
  URL: http://localhost:5000/logicmonitor

HTTP Status: 200

Check AAP Controller for 'Reset BGP Session' job execution.
Expected: Job launched targeting router2.
```

After running the script, verify in the AAP Controller UI:
- A "Reset BGP Session" job was launched
- The job targeted `router2`
- The job completed successfully

### 2.5 Restore BGP (if needed)

If the Crawl job did not run (or failed before enabling the link), bring the interface back up:

```bash
ansible-playbook playbooks/simulate_bgp_down.yml -i inventory/hosts.yml --tags restore
```

Or SSH into `router2` and run:

```
router2# configure
router2(config)# interface Ethernet1
router2(config-if)# no shutdown
```

Re-validate:

```bash
ansible-playbook playbooks/validate_bgp.yml -i inventory/hosts.yml
```

---

## Part 3: Walk Stage Demo

**Goal:** Demonstrate AI-enriched remediation where Edwin AI determines the root cause and the workflow branches accordingly.

Two scenarios are provided. Run them independently.

### Scenario A: Interface Errors

#### 3A.1 Simulate Interface Errors

Flap an interface to generate error counters and BGP instability:

```bash
ansible-playbook playbooks/simulate_interface_errors.yml -i inventory/hosts.yml
```

This flaps `Ethernet1` on `router2` three times (down/up cycles with 3-second pauses), generating interface error counters and triggering BGP instability alerts in LogicMonitor.

#### 3A.2 Observe the End-to-End Flow

1. **LogicMonitor** detects BGP flapping with correlated interface error alerts
2. **LM webhook** delivers a `bgp_flapping` alert to EDA
3. **EDA rulebook** matches the Walk rule, triggers "BGP Smart Remediation" workflow
4. **Workflow Node 1:** "Enrich with Edwin AI" queries Edwin AI for correlated alerts
5. Edwin AI returns: BGP flapping + interface error counters spiking -- root cause: `interface_errors`
6. **Workflow Node 2a:** "Bounce Interface" runs, bouncing the affected interface cleanly
7. BGP re-establishes after the clean bounce
8. Results reported back to LogicMonitor

In the AAP Controller, verify:
- The "BGP Smart Remediation" workflow launched
- The "Enrich with Edwin AI" node completed first
- The workflow artifacts show `root_cause: interface_errors`
- The "Bounce Interface" branch executed (not "Rollback Config")

### Scenario B: Config Drift

#### 3B.1 Simulate Configuration Drift

Introduce a wrong AS number in the BGP configuration:

```bash
ansible-playbook playbooks/simulate_config_drift.yml -i inventory/hosts.yml
```

This first copies running-config to `flash:lm-aiops-known-good` on `router2` (BGP must already be `Estab`), then changes the neighbor AS for `10.1.12.1` (router1) from `64501` to `99999`. The snapshot is on the device so the AAP rollback job can see it. Do not run simulate twice without rollback — the playbook refuses to snapshot a broken mesh. Do not `write memory` after simulate.

#### 3B.2 Observe the End-to-End Flow

1. **LogicMonitor** detects BGP failure with a correlated config change event
2. **LM webhook** delivers a `bgp_flapping` alert to EDA
3. **EDA rulebook** matches the Walk rule, triggers "BGP Smart Remediation" workflow
4. **Workflow Node 1:** "Enrich with Edwin AI" queries Edwin AI
5. Edwin AI returns: BGP failure + config change event 5 minutes ago -- root cause: `config_drift`
6. **Workflow Node 2c:** "Rollback Config" runs `configure replace flash:lm-aiops-known-good` (the simulate snapshot). If that file is missing, it falls back to device `startup-config` (ContainerLab deploy).
7. BGP re-establishes with the correct AS numbers
8. Results reported back to LogicMonitor

In the AAP Controller, verify:
- The "BGP Smart Remediation" workflow launched
- The workflow artifacts show `root_cause: config_drift`
- The "Rollback Config" branch executed (not "Bounce Interface")

### Walk Stage Validation

```bash
bash validation/test_walk.sh
```

Expected output:

```
=== Walk Stage Validation ===
Sending BGP flapping alert to EDA...
  URL: http://localhost:5000/logicmonitor

HTTP Status: 200

Check AAP Controller for 'BGP Smart Remediation' workflow execution.
Expected: Workflow launches, first node queries Edwin AI, then branches.
```

After running the script, verify in the AAP Controller UI:
- A "BGP Smart Remediation" workflow was launched
- The enrichment node ran first
- The correct remediation branch executed based on the root cause

---

## Part 4: Run Stage Demo

**Goal:** Demonstrate agentic AIOps where an unknown alert type escalates to Edwin AI for MCP-based investigation.

### 4.1 Simulate Unknown Alert

Send an alert type that does not match any Crawl or Walk rule:

```bash
ansible-playbook playbooks/simulate_unknown_alert.yml -i inventory/hosts.yml
```

This sends a `network_anomaly_unknown` alert to the EDA webhook with:
- Severity: critical
- Host: router1
- Anomaly score: 0.92
- Affected interfaces: Ethernet1, Ethernet2

### 4.2 Observe the End-to-End Flow

1. **EDA rulebook** evaluates the alert
2. No specific Crawl or Walk rule matches `network_anomaly_unknown`
3. **Catch-all rule** fires: "Unmatched alert - escalate to Edwin AI"
4. **EDA** triggers the "Escalate to Edwin AI" job template
5. The playbook sends the raw alert context to Edwin AI
6. **Edwin AI** connects to the AAP MCP Server and investigates:
   - Discovers available job templates and workflows
   - Queries inventory for affected device details
   - Checks recent job history
   - Formulates a remediation recommendation
7. Recommendation presented for human approval (or auto-approved per policy)

In the AAP Controller, verify:
- The "Escalate to Edwin AI" job launched (not "Reset BGP Session" or the workflow)
- The job received the full raw alert payload
- The job completed successfully

### 4.3 Run the Validation Script

```bash
bash validation/test_run.sh
```

Expected output:

```
=== Run Stage Validation ===
Sending unknown alert type to EDA...
  URL: http://localhost:5000/logicmonitor

HTTP Status: 200

Check AAP Controller for 'Escalate to Edwin AI' job execution.
Expected: Job launches, sends context to Edwin AI for MCP-based investigation.
```

---

## Part 5: Cleanup

Destroy the ContainerLab topology:

```bash
sudo containerlab destroy -t containerlab/bgp-topology.yml
```

This removes all three router containers and the lab network links.

---

## Troubleshooting

### Lab Environment Issues

| Issue | Cause | Resolution |
|-------|-------|------------|
| `containerlab deploy` fails with Docker error | Docker is not running or not accessible | Start Docker: `sudo systemctl start docker`. Verify: `docker ps` |
| `containerlab deploy` fails with image error | `ceos:latest` image not found | Import the Arista cEOS image: `docker import <ceos-image>.tar.xz ceos:latest` |
| Cannot SSH to routers | Containers not ready or wrong hostname | Wait 30-60 seconds after deploy. Verify container names with `sudo containerlab inspect` |
| `ansible-playbook` cannot reach routers | `ansible_host` does not resolve to clab container | Verify `clab-lm-aiops-bgp-<router>` entries exist in `/etc/hosts` (ContainerLab adds them) or that Docker DNS resolves the names |
| BGP not establishing after deploy | Routers still initializing | cEOS takes 30-60 seconds to fully boot. Wait and re-check with `show ip bgp summary` |

### AAP and EDA Issues

| Issue | Cause | Resolution |
|-------|-------|------------|
| Bootstrap playbook fails | Wrong Controller URL or credentials, or password unset | Export `CONTROLLER_HOST` / `CONTROLLER_USERNAME` / `CONTROLLER_PASSWORD`, or pass `-e @lab-automation/credentials.yml`. There is no default password. |
| EDA webhook not receiving alerts | Event Stream misconfigured, HMAC mismatch, or activation not started | Verify Event Stream URL (or port 5000 for standalone). Custom HTTP cannot HMAC-sign -- use Token Event Stream or `validation/test_*.sh` for HMAC tests |
| Live LM alert hits catch-all / no JT | Native `##ALERTTYPE##` used instead of hardcoded `type` | Paste `lab-automation/lm-webhook/*.json` as Raw JSON. Confirm LM device name matches inventory hostname |
| Wrong job template launches | Rulebook rule ordering | Rules are evaluated top-to-bottom. Verify specific rules (Crawl, Walk) appear before the catch-all (Run) in `rulebooks/logicmonitor_network.yml` |
| Job template fails with credential error | LM or Edwin AI credentials not created | Create credentials manually using the custom credential types created by the bootstrap |
| Workflow does not branch correctly | Root cause artifact not set or unexpected value | Check the "Enrich with Edwin AI" job output for `set_stats` artifacts. Review the enrichment playbook logic |

### Integration Issues

| Issue | Cause | Resolution |
|-------|-------|------------|
| LM webhook not reaching EDA | Firewall, incorrect URL, or EDA activation not running | Verify network connectivity to EDA port 5000. Check rulebook activation status in EDA Controller |
| Edwin AI query returns empty results | Incorrect credentials, wrong portal name, or no alerts in lookback window | Verify Edwin AI credential type is attached to the job template. Check `edwin_lookback_window` value |
| Edwin AI timeout during enrichment | Network latency or Edwin AI portal outage | The workflow failure fallback triggers the default BGP reset (Crawl behavior) |
| MCP Server not connecting | AAP MCP Server not deployed, or toolsets not enabled | Verify `aap-mcp-server` is running. Check toolset configuration includes `job_management` and `inventory_management` |
| LM alert not acknowledged after remediation | LM API credentials wrong or alert ID mismatch | Verify the "LogicMonitor API" credential has correct company name and bearer token |
