# leogallego.logicmonitor_mcp

Ansible collection generated from MCP server tools by [AnsibleClaw](https://github.com/leogallego/ansibleclawed).

Each module wraps an MCP tool with typed `argument_spec` validation and full documentation,
delegating to `ansible.mcp.run_tool` at runtime.

## Requirements

- `ansible-core` >= 2.16.0
- `ansible.mcp` collection installed
- MCP server accessible via `ansible.mcp.mcp` connection

## Installation

```bash
ansible-galaxy collection install leogallego.logicmonitor_mcp
```

## Usage

Configure your inventory to use the MCP connection:

```yaml
# inventory/hosts.yml
all:
  hosts:
    mcp_server:
      ansible_connection: ansible.mcp.mcp
      ansible_mcp_server_name: "your_server_name"
```

Then use any module in your playbooks:

```yaml
---
- name: Example playbook
  hosts: mcp_server
  gather_facts: false
  tasks:
    - name: Generate a direct URL/link/weburl for a LogicMonitor (LM) alert. 

**Returns:** Direct URL to alert details page. URL pattern: https://test.logicmonitor.com/santaba/uiv4/alerts/{alertId}

**When to use:** 
- Include alert links in Slack/PagerDuty notifications
- Share alert context with team members
- Create incident tickets with direct alert references
- Build alert reports with clickable links

**Why use this:** Simplifies alert investigation by providing direct navigation to the alert details page with full context, history, and acknowledgement options. 

**Workflow:** Get alertId from "list\_alerts", then use this tool to generate the shareable link for team collaboration. 

**Related tools:** "list\_alerts" (find alerts), "get\_alert" (get details), "acknowledge\_alert" (acknowledge).
      leogallego.logicmonitor_mcp.generate_alert_link:
        alertId: "CHANGEME"
      register: result
```

## Included modules

| Module | Description |
|--------|-------------|
| `generate_alert_link` | Generate a direct URL/link/weburl for a LogicMonitor (LM) alert. 

**Returns:** Direct URL to alert details page. URL pattern: https://test.logicmonitor.com/santaba/uiv4/alerts/{alertId}

**When to use:** 
- Include alert links in Slack/PagerDuty notifications
- Share alert context with team members
- Create incident tickets with direct alert references
- Build alert reports with clickable links

**Why use this:** Simplifies alert investigation by providing direct navigation to the alert details page with full context, history, and acknowledgement options. 

**Workflow:** Get alertId from "list\_alerts", then use this tool to generate the shareable link for team collaboration. 

**Related tools:** "list\_alerts" (find alerts), "get\_alert" (get details), "acknowledge\_alert" (acknowledge). |
| `generate_dashboard_link` | Generate a direct URL/link/weburl for a LogicMonitor (LM) dashboard. 

**Returns:** Complete dashboard URL with full group hierarchy path, dashboard details (id, name, groupName), and group path array. URL pattern: https://test.logicmonitor.com/santaba/uiv4/dashboards/dashboardGroups-{path},dashboards-{id}

**When to use:** 
- Share dashboard links in Slack/email/tickets
- Create documentation with direct dashboard links
- Embed dashboard URLs in runbooks
- Build custom reports with clickable links

**Why use this:** Provides the complete navigable URL including all parent group IDs, so the link opens the dashboard in correct context within the UI navigation tree. 

**Workflow:** First use "list\_dashboards" to find dashboard ID, then use this tool to generate the shareable link. 

**Related tools:** "list\_dashboards" (find dashboard), "get\_dashboard" (get details). |
| `generate_resource_link` | Generate a direct URL/link/weburl for a LogicMonitor (LM) resource/device. 

**Returns:** Complete resource URL with full group hierarchy, resource/device details (id, name, displayName), and group path array. URL pattern: https://test.logicmonitor.com/santaba/uiv4/resources/treeNodes?resourcePath=resourceGroups-{path},resources-{id}

**When to use:** 
- Share resource/device links in incident tickets
- Create alert notifications with resource/device links
- Build reports with clickable resource/device references
- Document infrastructure with direct LM links

**Why use this:** Provides the complete URL including all parent group IDs, so clicking the link navigates directly to the resource/device in the correct folder context. 

**Workflow:** First find resource/device using "list\_resources" or "search\_resources", then use this tool with deviceId to generate shareable link. 

**Related tools:** "list\_resources" (find device), "get\_resource" (get details), "generate\_alert\_link" (link to resource/device alerts). |
| `generate_website_link` | Generate a direct direct URL/link/weburl for a LogicMonitor (LM) website monitor with full hierarchy path for easy sharing and navigation. 

**What this does:** Creates shareable URL that opens specific website monitor in LogicMonitor UI, preserving the full folder hierarchy path. Link works for anyone with access to the LogicMonitor portal. 

**Returns:** Complete URL in format: https://test.logicmonitor.com/santaba/uiv4/websites/treeNodes#websiteGroups-{groupId1},websiteGroups-{groupId2},...,websites-{websiteId} 

**When to use:** 
- Share website monitor with team (Slack/email/tickets)
- Create documentation with direct links
- Build custom dashboards/reports with LM links
- Reference in incident tickets
- Bookmark frequently accessed monitors

**Required parameters:** 
- websiteId: Website monitor ID (from "list\_websites" or "search\_websites")

**Common use cases:** 

**Share in Slack/Teams:** "Production API health check is failing: [View Monitor](generated-url-here)" 

**Incident ticket documentation:** "INC-12345: Website monitor showing SSL certificate expiring in 7 days. See: {generated-url}" 

**Runbook links:** "If homepage monitoring alerts, check: {generated-url-for-homepage-monitor}" 

**Custom reporting:** Build report that includes clickable links to each website monitor for quick access. 

**Link structure explained:** The URL includes complete folder path (websiteGroups) so when clicked, the UI shows: 
- Full breadcrumb navigation (e.g., "All Website Monitors > Production > External APIs > Homepage Check")
- Website monitor details page
- Recent check history and availability
- Current status and response times

**Why use generated links:** 
- **Shareable:** Send exact monitor to teammates
- **Bookmarkable:** Save frequent monitors for quick access
- **Integration-friendly:** Use in external tools, tickets, wikis
- **Context-preserving:** Shows full folder hierarchy when opened

**Workflow example:** 
- Find website monitor: list_websites() → websiteId: 789
- Generate link: generate_website_link(websiteId: 789)
- Share link: "Check this monitor: https://company.logicmonitor.com/santaba/uiv4/websites/..."

**Access requirements:** Link recipients must: 
- Have LogicMonitor user account
- Have permissions to view website monitors
- Have access to specific website monitor (based on access groups)

**Best practices:** 
- Use in incident documentation for traceability
- Include in runbooks for quick troubleshooting access
- Add to monitoring dashboards for drill-down capability
- Share with stakeholders who have LM access

**Related tools:** "list\_websites" (find website), "get\_website" (verify details), "generate\_dashboard\_link" (for dashboards), "generate\_resource\_link" (for resources/devices), "generate\_alert\_link" (for alerts). |
| `get_access_group` | Get detailed information about a specific access group in LogicMonitor (LM) monitoring by its ID. 

**Returns:** Complete access group details: name, description, tenant ID, list of associated resources (which resources/devices/groups are in this access group), list of users assigned to this access group. 

**When to use:** 
- Review which resources are in this access group
- Check which users have access to this group
- Audit access control before modifications
- Verify tenant isolation configuration

**Key information returned:** 
- **Resources:** Which resource/device groups and resources users in this access group can see
- **Users:** Which users are assigned to this access group
- **Tenant ID:** Multi-tenant identifier (MSP environments)

**Impact analysis:** Before modifying access group: 
- Removing resource: Users lose visibility to those resource/device
- Removing user: User loses visibility to all resources in group
- Deleting group: All users lose their access scope

**Workflow:** Use "list\_access\_groups" to find accessGroupId, then use this tool to review complete configuration before modifications. 

**Related tools:** "list\_access\_groups" (find groups), "update\_access\_group" (modify), "list\_users" (see user access). |
| `get_alert` | Get detailed information about a specific alert in LogicMonitor (LM) monitoring by its ID. 

**Returns:** Complete alert details: alert message, severity, threshold crossed, current value, alert history, escalation chain triggered, acknowledgement details, resource details, datasource/datapoint info, alert rule applied. 

**When to use:** 
- Investigate specific alert after getting ID from "list\_alerts"
- Check threshold and current values
- Review alert history and escalation
- Get context before acknowledging

**Workflow:** First use "list\_alerts" to find the alertId, then use this tool for complete investigation details. 

**Related tools:** "acknowledge\_alert" (acknowledge alert), "add\_alert\_note" (document findings), "generate\_alert\_link" (share with team). |
| `get_alert_rule` | Get detailed information about a specific alert rule by ID in LogicMonitor (LM) monitoring. 

**Returns:** Complete alert rule details: name, priority, enabled status, detailed matching conditions (device groups, datasources, datapoints, instance filters, severity levels), escalation chain assignment, suppression windows, notification settings. 

**When to use:**
- Review exact matching logic before modifying rule
- Troubleshoot why alert matched (or didn't match) this rule
- Document alert routing policies
- Verify suppression settings
- Check which escalation chain receives matching alerts


**Matching conditions explained:** 
- deviceGroups: Which resource/device folders this rule applies to (e.g., /Production/, /Database Servers/) 
- datasources: Which datasources trigger this rule (e.g., CPU, Memory, AWS_EC2) 
- datapoints: Specific metrics (e.g., CPUBusyPercent, MemoryUsedPercent) 
- instances: Filter by instance name (e.g., C: drive only, eth0 interface only) 
- severity: Alert levels (critical, error, warn) 
- escalatingChainId: Where matching alerts are routed 

**Troubleshooting use cases:** 
- "Why did this CPU alert go to wrong team?" → Check resource/device group + datasource filters 
- "Why didn't I get paged?" → Verify alert matches conditions AND check escalation chain 
- "Too many alerts" → Review if conditions too broad, add instance filters 

**Workflow:** Use "list\_alert\_rules" to find ruleId, then use this tool to review complete matching logic and routing. 

**Related tools:** "list\_alert\_rules" (find rules), "update\_alert\_rule" (modify), "get\_escalation\_chain" (check notification chain). |
| `get_audit_log` | Get detailed information about a specific audit log entry in LogicMonitor (LM) monitoring by its ID. 

**Returns:** Complete audit log details: username, IP address, exact timestamp, full description of action, session ID, affected resources, before/after values (for updates). 

**When to use:** 
- Get complete details after finding log ID via "list\_audit\_logs"
- Review exact changes made (old vs new values)
- Investigate specific incident with full context

**Workflow:** First use "list\_audit\_logs" with filters to find relevant entries, then use this tool with the log ID for complete details. 

**Related tools:** "list\_audit\_logs" (search logs), "search\_audit\_logs" (text search). |
| `get_collector` | Get detailed information about a specific collector by its ID in LogicMonitor (LM) monitoring. 

**Returns:** Complete collector details: description (name), hostname, platform, status, build version, number of resource/device monitored, free disk space, CPU/memory usage, last heartbeat, configuration. 

**When to use:** 
- Check collector health before assigning resources/devices
- Verify collector capacity
- Troubleshoot connectivity issues
- Check version for updates
- Monitor collector performance

**Health indicators to check:** 
- status: "alive" (healthy) vs "dead" (offline/problem)
- numberOfHosts: How many resource/device this collector monitors (capacity planning)
- freeDiskSpace: Disk space available (needs GB for data buffering)
- build: Version number (compare with "list\_collector\_versions" for updates)
- lastHeartbeatTime: Recent = healthy, old = potential issue

**Workflow:** Use "list\_collectors" to find collectorId, then use this tool for detailed health check. 

**Related tools:** "list\_collectors" (find collector), "list\_collector\_versions" (check updates), "list\_resources" (see assigned resources/devices). |
| `get_collector_group` | Get detailed information about a specific collector group by ID in LogicMonitor (LM) monitoring. 

**Returns:** Complete collector group details: name, full path, parentId, description, number of collectors (direct and total), number of subgroups. 

**When to use:**
- Get group path for documentation
- Check collector membership counts
- Verify group hierarchy
- Review group structure before deploying collectors


**Workflow:** Use "list\_collector\_groups" to find groupId, then use this tool for complete details. 

**Related tools:** "list\_collector\_groups" (find groups), "list\_collectors" (collectors in group), "create\_collector\_group" (create new). |
| `get_configsource` | Get detailed information about a specific ConfigSource by its ID in LogicMonitor (LM) monitoring. 

**Returns:** Complete ConfigSource details: name, displayName, description, appliesTo logic (which resources/devices), collection method (CLI/SNMP/API), collection script, alert settings. 

**When to use:** 
- Understand what config is being collected
- Review appliesTo logic (why it does/doesn't apply to device)
- Check collection method
- Troubleshoot config collection issues

**Key information:** 
- appliesTo: Logic determining which resource/device get config tracking
- collectMethod: How config is retrieved (CLI commands, SNMP, API)
- configAlerts: Settings for when to alert on changes
- lineageId: Built-in (LogicMonitor) vs custom ConfigSource

**Workflow:** Use "list\_configsources" to find configSourceId, then use this tool to understand how it works. 

**Related tools:** "list\_configsources" (find ConfigSource), "list\_device\_configs" (see configs for device). |
| `get_dashboard` | Get detailed information about a specific dashboard by its ID in LogicMonitor (LM) monitoring. 

**Returns:** Complete dashboard details: name, description, groupId, owner, widgets configuration, widget count, sharing settings, template variables, last modified. 

**When to use:** 
- Review dashboard configuration
- See widget definitions before cloning
- Check dashboard owner
- Verify template variables
- Get dashboard metadata

**What you get:** 
- widgetsConfig: JSON configuration of all widgets (chart types, metrics, thresholds)
- widgetTokens: Template variables (e.g., defaultDeviceGroup for dynamic filtering)
- groupId/groupName: Which folder dashboard is in
- sharable: Whether dashboard is public/private

**Use cases:** 
- Clone dashboard to create similar one
- Export dashboard configuration for backup
- Audit which resources/devices/metrics are being visualized
- Document dashboard purpose and widgets

**Workflow:** Use "list\_dashboards" to find dashboardId, then get details, then "generate\_dashboard\_link" to get shareable URL. 

**Related tools:** "list\_dashboards" (find dashboard), "generate\_dashboard\_link" (get URL), "update\_dashboard" (modify), "list\_dashboard\_groups" (browse folders). |
| `get_dashboard_group` | Get detailed information about a specific dashboard group by its ID in LogicMonitor (LM) monitoring. 

**Returns:** Complete dashboard group details: name, full path, parentId, description, number of dashboards (direct and total), number of subgroups, owner, permissions. 

**When to use:** 
- Get group path for documentation
- Check group membership counts
- Verify group hierarchy
- Review permissions before creating dashboards in it

**Workflow:** Use "list\_dashboard\_groups" to find groupId, then use this tool for complete details. 

**Related tools:** "list\_dashboard\_groups" (find groups), "list\_dashboards" (dashboards in group), "create\_dashboard\_group" (create new). |
| `get_datasource` | Get detailed information about a specific datasource by its ID in LogicMonitor (LM) monitoring. 

**Returns:** Complete datasource details: name, displayName, description, appliesTo logic, collection method, datapoints (metrics), thresholds, alert rules, polling interval. 

**When to use:** 
- Understand what datasource monitors
- Review alert thresholds
- See collection method (SNMP/WMI/API/script)
- Check datapoint definitions
- Troubleshoot why datasource applies/doesn't apply to device

**Key information returned:** 
- appliesTo: Logic determining which resource/device get this datasource (e.g., "system.hostname =\~\"\*prod\*\"")
- dataSourceType: Collection method (SNMP, WMI, JDBC, API, script)
- dataPoints: List of metrics collected (e.g., CPUBusyPercent, MemoryUsedPercent)
- alertExpr: Threshold formulas (when to alert)
- collectInterval: How often data is collected (seconds)

**Understanding appliesTo logic:** Shows why datasource does/doesn't monitor certain resources/devices. Common patterns: 
- isWindows() - Only Windows resource/device
- system.devicetype == "server" - Only servers
- hasCategory("AWS/EC2") - Only AWS EC2 instances

**Workflow:** Use "list\_datasources" to find dataSourceId, then use this tool to understand how it works. 

**Related tools:** "list\_datasources" (find datasource), "list\_resource\_datasources" (see which resource/device use it). |
| `get_escalation_chain` | Get detailed information about a specific escalation chain by its ID in LogicMonitor (LM) monitoring. 

**Returns:** Complete escalation chain details: name, description, all stages with: recipients at each stage, notification methods (email/SMS/webhook), time delays between stages, rate limiting, business hours restrictions. 

**When to use:**
- Review detailed notification workflow
- Verify who gets notified at each stage
- Check timing between escalations
- Audit notification methods
- Troubleshoot why notifications not received


**Stage details returned:** For each stage: 
- Stage number (1, 2, 3...) 
- Delay before stage triggers (minutes) 
- Recipients/groups notified 
- Notification methods (email, SMS, integration) 
- Schedule (24/7 vs business hours only) 

**Example escalation chain details:** Stage 1 (0 min): Email "oncall@company.com", SMS "+1-555-1234" Stage 2 (15 min): PagerDuty integration, Email "team-lead@company.com" Stage 3 (30 min): Slack webhook, Email "engineering-manager@company.com" 

**Workflow:** Use "list\_escalation\_chains" to find chainId, then use this tool to review complete notification workflow. 

**Related tools:** "list\_escalation\_chains" (find chains), "update\_escalation\_chain" (modify), "list\_recipients" (see recipients). |
| `get_eventsource` | Get detailed information about a specific EventSource by its ID in LogicMonitor (LM) monitoring. 

**Returns:** Complete EventSource details: name, displayName, description, appliesTo logic, collection method, filter rules, severity mapping, alert settings. 

**When to use:**
- Understand what events are collected
- Review filter rules (which events trigger alerts)
- Check severity mapping
- Troubleshoot event collection
- See appliesTo logic


**Key information:** 
- appliesTo: Which resources/devicesget event monitoring 
- filters: Rules for parsing/matching events 
- severityMapping: Map event levels (INFO/WARN/ERROR) to LM alert levels 
- schedule: When event collection runs 

**Workflow:** Use "list\_eventsources" to find eventSourceId, then use this tool for complete configuration. 

**Related tools:** "list\_eventsources" (find EventSource), "list\_device\_eventsources" (events for device). |
| `get_integration` | Get detailed information about a specific integration by ID in LogicMonitor (LM) monitoring. 

**Returns:** Complete integration details: name, type, configuration (API keys, webhooks, URLs), authentication status, last successful notification, error logs, which escalation chains use it. 

**When to use:**
- Troubleshoot integration not working
- Review configuration before updates
- Check API keys/authentication
- See last successful notification time
- Audit integration settings


**Configuration details by type:** 
- **Slack:** Webhook URL, channel names, mention settings 
- **PagerDuty:** Integration key, service mappings 
- **ServiceNow:** Instance URL, credentials, table mapping 
- **Jira:** Project keys, issue type, custom field mapping 
- **Webhook:** Target URL, authentication headers, payload format 

**Troubleshooting:** 
- Authentication failed: Check API keys/credentials 
- Not receiving notifications: Verify escalation chain configuration 
- Error logs: Review failed notification attempts 

**Workflow:** Use "list\_integrations" to find integrationId, then use this tool for detailed configuration and troubleshooting. 

**Related tools:** "list\_integrations" (find integrations), "test\_integration" (send test), "update\_integration" (modify). |
| `get_netscan` | Get detailed information about a specific netscan by ID in LogicMonitor (LM) monitoring. 

**Returns:** Complete netscan details: name, description, scan method, schedule, target networks/IPs, credentials, filters (include/exclude rules), resource/device properties to apply, collector assignment, duplicate detection settings, last execution results. 

**When to use:**
- Review netscan configuration before running
- Troubleshoot why certain resource/device not discovered
- Check credentials and filters
- Verify resource/device properties applied to discovered resources/devices
- Understand duplicate detection logic


**Configuration details returned:** 
- **Targets:** IP ranges, subnets, or cloud filters (e.g., "192.168.1.0/24", "All EC2 with tag:Environment=prod") 
- **Schedule:** How often scan runs (hourly, daily, weekly, on-demand) 
- **Credentials:** Which properties used for authentication (ssh.user, snmp.community) 
- **Filters:** Include/exclude rules (e.g., "Exclude IPs ending in .1", "Only Linux servers") 
- **Device properties:** Auto-applied to discovered resource/device (e.g., location, environment tags) 
- **Duplicate handling:** How to handle resource/device found in multiple scans 

**Troubleshooting use cases:** 
- "Why resource/device not discovered?" → Check if IP in target range and not excluded by filters 
- "Wrong credentials?" → Verify credential properties configured in netscan 
- "resources/Devices missing properties?" → Check default properties applied by netscan 

**Workflow:** Use "list\_netscans" to find netscanId, then use this tool to review complete configuration. 

**Related tools:** "list\_netscans" (find netscan), "update\_netscan" (modify), "run\_netscan" (execute now). |
| `get_opsnote` | Get detailed information about a specific operational note by ID in LogicMonitor (LM) monitoring. 

**Returns:** Complete OpsNote details: note text, timestamp, creator, tags, scope (resources/devices/groups affected), related SDTs, linked resources. 

**When to use:**
- Get full note details after finding ID via list
- Review what was documented at specific time
- Check scope of operational event
- Verify linked resources


**Workflow:** Use "list\_opsnotes" to find note ID, then use this tool for complete details. 

**Related tools:** "list\_opsnotes" (find notes), "create\_opsnote" (add new), "update\_opsnote" (modify). |
| `get_recipient` | Get detailed information about a specific recipient by ID in LogicMonitor (LM) monitoring. 

**Returns:** Complete recipient details: type, name, contact information (email/phone/URL), notification method, timezone, schedule restrictions, rate limiting settings. 

**When to use:**
- Verify contact information before escalation
- Check notification schedule (business hours vs 24/7)
- Review rate limiting settings
- Audit recipient configuration


**Details returned:** 
- Contact info: Exact email/phone/webhook URL 
- Schedule: When notifications are sent (always vs business hours) 
- Rate limit: Max notifications per time period (prevent notification fatigue) 
- Method: Delivery mechanism (SMTP, Twilio, webhook) 

**Workflow:** Use "list\_recipients" to find recipientId, then use this tool for complete configuration. 

**Related tools:** "list\_recipients" (find recipient), "update\_recipient" (modify), "list\_escalation\_chains" (usage). |
| `get_recipient_group` | Get detailed information about a specific recipient group by ID in LogicMonitor (LM) monitoring. 

**Returns:** Complete recipient group details: name, description, list of all members (recipients), member contact info, escalation chains using this group. 

**When to use:**
- Review group membership before modifications
- Verify who gets notified through this group
- Check which escalation chains use this group
- Audit team notification lists


**Key information returned:** 
- Members: All recipients in group (names, emails, phones) 
- Usage: Which escalation chains reference this group 
- Description: Purpose/team name 

**Before modifying group:** Review escalation chain usage to understand impact of changes. Removing member from group affects all chains using that group. 

**Workflow:** Use "list\_recipient\_groups" to find groupId, then use this tool to review membership before updating. 

**Related tools:** "list\_recipient\_groups" (find groups), "update\_recipient\_group" (modify), "list\_escalation\_chains" (see where used). |
| `get_report` | Get detailed information about a specific report by its ID in LogicMonitor (LM) monitoring. 

**Returns:** Complete report details: name, type, description, schedule (daily/weekly/monthly), recipients, format, data sources (which resources/devices/groups), date range, customization settings, last run timestamp, delivery status. 

**When to use:** 
- Review report configuration before modification
- Check recipients and schedule
- Verify data sources (which resource/device included)
- Troubleshoot why report not received
- Clone report settings for similar report

**Configuration details:** 
- Schedule: When report runs (e.g., "Every Monday at 8am")
- Recipients: Who receives report via email
- Format: PDF (management), HTML (web), CSV (data analysis)
- Scope: Which resources/devices/groups are included
- Date range: Last 7 days, last month, custom period

**Workflow:** Use "list\_reports" to find reportId, then use this tool for complete configuration. 

**Related tools:** "list\_reports" (find reports), "update\_report" (modify), "generate\_report" (run now). |
| `get_report_group` | Get detailed information about a specific report group by ID in LogicMonitor (LM) monitoring. 

**Returns:** Complete report group details: name, full path, parentId, description, number of reports (direct and total), number of subgroups. 

**When to use:**
- Get group path for documentation
- Check report membership counts
- Verify group hierarchy
- Review group structure before creating reports


**Workflow:** Use "list\_report\_groups" to find groupId, then use this tool for complete details. 

**Related tools:** "list\_report\_groups" (find groups), "list\_reports" (reports in group), "create\_report\_group" (create new). |
| `get_resource` | Get detailed information about a specific resource/device in LogicMonitor (LM) monitoring by its ID. 

**Returns:** Complete resource/device details including: displayName, IP/hostname, hostStatus, alertStatus, collector assignment, resource/device type, custom properties, applied datasources, group memberships, last data time, creation date. 

**When to use:** 
- Get full details after finding resource/device ID via "list\_resources"
- Check resource/device configuration
- Verify collector assignment
- Review custom properties before updating

**Workflow:** Use "list\_resources" or "search\_resources" first to find the deviceId, then use this tool for complete details. 

**Related tools:** "list\_resource\_datasources" (see what's monitored), "list\_resource\_properties" (view all properties), "generate\_resource\_link" (get UI link). |
| `get_resource_datasource` | Get detailed information about a specific datasource applied to a resource/device in LogicMonitor (LM) monitoring. 

**Returns:** Complete resource/device datasource details: dataSourceName, status, alert status, number of instances, monitoring configuration, stop monitoring flag, custom properties, graphs. 

**When to use:**
- Check if datasource is collecting data
- Review alert status for specific datasource
- Verify custom thresholds
- Get deviceDataSourceId for instance operations
- Troubleshoot data collection issues


**Key fields:** 
- instanceNumber: How many instances (e.g., 4 network interfaces) 
- status: Collection status (normal vs error) 
- alertStatus: Any active alerts from this datasource 
- stopMonitoring: Whether datasource is disabled on this resource/device 

**Workflow:** Use "list\_device\_datasources" to find deviceDataSourceId, then use this tool for detailed status. 

**Related tools:** "list\_device\_datasources" (find datasource), "list\_device\_instances" (get instances), "update\_device\_datasource" (enable/disable). |
| `get_resource_group` | Get detailed information about a specific resource/device group by its ID in LogicMonitor (LM) monitoring. 

**Returns:** Complete group details: name, full path, parentId, description, custom properties, number of resource/device (direct and total), number of subgroups, alert status, SDT status. 

**When to use:** 
- Get group path for documentation
- Review inherited properties
- Check group membership counts
- Verify group hierarchy
- Get group details before creating resource/device in it

**Key information:** 
- fullPath: Complete hierarchy (e.g., "/Production/Web Servers/US-East")
- customProperties: Properties inherited by all resource/device in group
- numOfDirectDevices: resources/Devices directly in this group
- numOfHosts: Total resource/device including subgroups
- alertStatus: Rollup alert status for entire group

**Custom properties inheritance:** Properties set on group are inherited by ALL resource/device in group. Common uses: 
- Credentials: {name: "ssh.user", value: "monitoring"}
- Environment tags: {name: "env", value: "production"}
- Owner: {name: "team", value: "platform-engineering"}

**Workflow:** Use "list\_resource\_groups" to find groupId, then use this tool for complete details including inherited properties. 

**Related tools:** "list\_resource\_groups" (find groups), "create\_resource\_group" (create new), "list\_resources" (devices in group). |
| `get_resource_instance_data` | Get time-series metrics/datapoints data (e.g., CPU/memory/network utilization) for a specific resource/device datasource instance in LogicMonitor (LM) monitoring. 

**Returns:** Time-series data with timestamps and values for requested datapoints. Format: {timestamps: [epoch1, epoch2], values: {datapoint1: [val1, val2], datapoint2: [val1, val2]}}. 

**When to use:** 
- Get CPU utilization for last 24 hours
- Fetch disk usage trends
- Retrieve network bandwidth data
- Export metrics for analysis
- Build custom dashboards/reports

**Required workflow (3 steps):** 
- Use "list\_resource\_datasources" → get deviceDataSourceId for datasource (e.g., WinCPU)
- Use "list\_resource\_instances" → get instanceId for specific instance (e.g., CPU Core 0)
- Use this tool → get actual metric values for that instance

**Parameters:** 
- deviceId: Device ID from "get\_resource" or "list\_resources"
- deviceDataSourceId: From "get\_resource\_datasource" or "list\_resource\_datasources"
- instanceId: From "list\_resource\_instances"
- datapoints: Comma-separated metric names (e.g., "CPUBusyPercent,MemoryUsedPercent")
- start/end: Time range in epoch milliseconds (not seconds!), start time must be before current time

**Example:** Get last hour CPU data: start=Date.now()-3600000, end=Date.now() 

**Time range tips:** If omitted, returns last 2 hours. Max range: 1 year. Use shorter ranges for better performance. 

**Related tools:** "list\_resource\_datasources", "list\_resource\_instances". |
| `get_role` | Get detailed information about a specific role by its ID in LogicMonitor (LM) monitoring. 

**Returns:** Complete role details: name, description, custom flag, detailed permission matrix (view/manage/delete/acknowledge for each area: resources/devices, alerts, dashboards, reports, settings, users). 

**When to use:** 
- Review exact permissions before assigning role
- Compare roles to choose correct one
- Document security policies
- Audit what a role can/cannot do
- Before creating custom role (use as template)

**Permission granularity returned:** 
- Resources: Can view/add/modify/delete resource/device
- Alerts: Can view/acknowledge/manage alert rules
- Dashboards: Can view/create/edit/delete dashboards
- Reports: Can view/create/schedule reports
- Settings: Can modify datasources/collectors/integrations
- Users: Can manage other users/roles

**Use cases:** 
- Security audit: "Can this role delete production resources/devices?"
- Least privilege: Choose role with minimal required permissions
- Documentation: Export role permissions for compliance
- Role comparison: Compare multiple roles to find right fit

**Workflow:** Use "list\_roles" to find roleId, then use this tool to review detailed permissions before assigning to users. 

**Related tools:** "list\_roles" (find roles), "list\_users" (see who has this role), "create\_role" (create custom role). |
| `get_sdt` | Get detailed information about a specific Scheduled Down Time (SDT) by its ID in LogicMonitor (LM) monitoring. 

**Returns:** Complete SDT details: type, device/group affected, start/end times, duration, comment, who created it, status (active/scheduled/expired), recurrence settings. 

**When to use:** 
- Verify SDT was created correctly
- Check when maintenance window ends
- See who scheduled downtime
- Get SDT details before extending/canceling
- Audit maintenance history

**Status meanings:** 
- scheduled: Future maintenance window (not started yet)
- active: Currently in maintenance window (alerts suppressed now)
- expired: Maintenance window completed (historical record)

**Workflow:** Use "list\_sdts" to find SDT ID, then use this tool for complete details before deciding to extend or delete. 

**Related tools:** "list\_sdts" (find SDTs), "create\_resource\_sdt" (create new), "delete\_sdt" (cancel). |
| `get_service` | Get detailed information about a specific service by ID in LogicMonitor (LM) monitoring. 

**Returns:** Complete service details: name, description, health status, dependency tree (all resources comprising service), SLA/SLO configuration, availability statistics, alert rules, service group. 

**When to use:**
- Review service dependencies (what resources are included)
- Check current health status and root cause
- Verify SLA/SLO configuration
- Troubleshoot service downtime
- Understand service architecture


**Key information returned:** 
- **Dependency tree:** All resources/devices/resources that comprise this service 
- **Health calculation:** How service status is determined (e.g., "If ANY web server is down, service is degraded") 
- **Current status:** Operational / Degraded / Down 
- **SLA metrics:** Uptime percentage, outage history 
- **Alert configuration:** When to alert on service issues 

**Troubleshooting workflow:** Service shows "Down" → Check dependency tree → Identify which specific resource(s) failed → Address those resources → Service auto-recovers when dependencies healthy 

**Workflow:** Use "list\_services" to find serviceId, then use this tool for complete dependency analysis. 

**Related tools:** "list\_services" (find service), "update\_service" (modify dependencies), "list\_resources" (see health of dependent resources). |
| `get_service_group` | Get detailed information about a specific service group by ID in LogicMonitor (LM) monitoring. 

**Returns:** Complete service group details: name, full path, parentId, description, number of services (direct and total), number of subgroups. 

**When to use:**
- Get group path for documentation
- Check service membership counts
- Verify group hierarchy
- Review group structure before creating services


**Workflow:** Use "list\_service\_groups" to find groupId, then use this tool for complete details. 

**Related tools:** "list\_service\_groups" (find groups), "list\_services" (services in group), "create\_service\_group" (create new). |
| `get_topology` | Get network topology information in LogicMonitor (LM) monitoring. 

**Returns:** Network topology data with: resource/device relationships, network connections, parent-child hierarchies, Layer 2/Layer 3 connectivity maps. 

**What is topology:** Automatically discovered network relationship map showing how resource/device connect to each other. LogicMonitor uses SNMP, CDP (Cisco Discovery Protocol), LLDP (Link Layer Discovery Protocol), and other methods to build network topology maps. 

**When to use:**
- Understand network architecture and resource/device relationships
- Visualize network connectivity
- Plan network changes
- Troubleshoot connectivity issues
- Document network infrastructure


**Topology information includes:** 
- **Physical connections:** Which resource/device are physically connected (switch ports, router interfaces) 
- **Logical relationships:** Parent-child relationships (gateway → firewall → switches → servers) 
- **Layer 2 topology:** MAC address tables, VLANs, switch port connections 
- **Layer 3 topology:** IP routing, subnets, default gateways 

**Use cases:** 
- **Network visualization:** See how your network is structured 
- **Impact analysis:** "If this switch fails, what resource/device lose connectivity?" 
- **Capacity planning:** Identify network bottlenecks and heavily-utilized links 
- **Documentation:** Auto-generated network diagrams 
- **Troubleshooting:** Trace connection paths between resource/device 

**How LogicMonitor discovers topology:** 
- CDP/LLDP: Cisco and other vendors broadcast neighbor information 
- SNMP: Query resource/device interface tables, ARP tables, routing tables 
- Traceroute: Active probing to discover paths 
- Parent/child relationships: Based on gateway configuration 

**Related tools:** "list\_resources" (view resources/devices), "get\_resource" (device details including connections). |
| `get_user` | Get detailed information about a specific user by their ID in LogicMonitor (LM) monitoring. 

**Returns:** Complete user details: username, email, firstName, lastName, roles (permissions), status (active/suspended), last login time, created date, phone, timezone, API token count, two-factor auth status. 

**When to use:** 
- Review user permissions and roles
- Check last login time (identify inactive users)
- Verify contact information
- Audit user access before modification
- Get user details for API token management

**Key information:** 
- roles: Array of role names (defines permissions)
- status: "active" (can login) vs "suspended" (access revoked)
- lastLoginOn: Epoch timestamp (identify inactive accounts)
- apiTokens: Number of active API tokens
- twoFAEnabled: Whether 2FA is configured

**Security audit use cases:** 
- Find users who haven't logged in for 90+ days
- Review which users have admin roles
- Check if former employees still have access
- Verify API token usage per user

**Workflow:** Use "list\_users" to find userId, then use this tool for complete user profile. 

**Related tools:** "list\_users" (find user), "list\_roles" (see available roles), "list\_api\_tokens" (view user's tokens), "update\_user" (modify). |
| `get_website` | Get detailed information about a specific website monitor by its ID in LogicMonitor (LM) monitoring. 

**Returns:** Complete website monitor details: name, type (webcheck/pingcheck), domain/URL, monitoring configuration, checkpoint locations, response time thresholds, SSL settings, authentication, custom headers, alert status. 

**When to use:** 
- Review monitoring configuration
- Check checkpoint locations
- Verify URL and settings
- Troubleshoot failed checks
- Audit SSL certificate monitoring

**Configuration details returned:** 
- steps: Multi-step transaction monitoring (for complex workflows)
- checkpoints: Which global locations perform checks (e.g., US-East, EU-West, Asia-Pacific)
- schema: HTTP vs HTTPS
- testLocation: Internal (from collector) vs External (from cloud)
- responseTimeThreshold: Alert if slower than X ms
- sslCertExpirationDays: Alert X days before cert expires

**Use cases:** 
- Verify website is monitored from correct geographic locations
- Check if SSL certificate expiration monitoring is enabled
- Review response time thresholds (too strict? too lenient?)
- Troubleshoot why website checks are failing
- Document what endpoints are monitored

**Workflow:** Use "list\_websites" to find websiteId, then use this tool for complete monitoring configuration. 

**Related tools:** "list\_websites" (find website), "update\_website" (modify), "generate\_website\_link" (get URL), "list\_website\_checkpoints" (available locations). |
| `get_website_group` | Get detailed information about a specific website group by its ID in LogicMonitor (LM) monitoring. 

**Returns:** Complete website group details: name, full path, parentId, description, number of websites (direct and total), number of subgroups, alert status. 

**When to use:** 
- Get group path for documentation
- Check website membership counts
- Verify group hierarchy
- Review group structure before creating monitors

**Workflow:** Use "list\_website\_groups" to find groupId, then use this tool for complete details. 

**Related tools:** "list\_website\_groups" (find groups), "list\_websites" (websites in group), "create\_website\_group" (create new). |
| `list_access_groups` | List all access groups in LogicMonitor (LM) monitoring. 

**Returns:** Array of access groups with: id, name, description, tenant ID, number of associated resources, number of users. 

**What are access groups:** Permission boundaries that control WHICH resources users can see and manage. Used in multi-tenant environments to isolate customer data, or to segment access by team/department. Users assigned to access group can only see resources in that group. 

**When to use:** 
- Manage multi-tenant environments (MSPs)
- Segment monitoring by department/team
- Control resource visibility
- Audit access control configuration
- Find access group IDs for user assignment

**Access groups vs Roles (important distinction):** 
- **Access Groups:** Control WHAT resources you can see (visibility, data isolation)
- **Roles:** Control WHAT actions you can perform (view/edit/delete permissions)
- Users need BOTH: Role (what they can do) + Access Group (what they can see)

**Common use cases:** 

**MSP / Multi-tenant:** 
- Access Group "Customer A" - User sees only Customer A resource/device
- Access Group "Customer B" - User sees only Customer B resource/device
- Prevents customers from seeing each other's data

**Departmental isolation:** 
- Access Group "Network Team" - See only network resource/device
- Access Group "Server Team" - See only servers
- Access Group "Database Team" - See only database servers

**Environment separation:** 
- Access Group "Production" - Only prod resource/device
- Access Group "Dev/Test" - Only non-prod resource/device
- Junior staff limited to dev/test access group

**Workflow:** Use this tool to find access groups, then assign users to groups via "update\_user" to control resource visibility. 

**Important:** A negative "total" value in the response indicates incomplete results. Use pagination (size/offset parameters) or set autoPaginate: true to retrieve all items. 

**Related tools:** "get\_access\_group" (details), "create\_access\_group" (create new), "list\_users" (see user assignments), "list\_resources" (associate resource/device with groups). |
| `list_alert_rules` | List all alert rules in LogicMonitor (LM) monitoring. 

**Returns:** Array of alert rules with: id, name, priority, enabled status, matching conditions (device/datasource/severity filters), escalation chain assigned, suppression settings. 

**What are alert rules:** The ROUTING LOGIC that determines "which alerts go to which people." Act as traffic directors: "IF alert matches these conditions, THEN send to this escalation chain." Rules are evaluated in priority order (1st match wins). 

**When to use:**
- Audit who gets notified for different alert types
- Understand notification routing logic
- Find rule IDs for modifications
- Troubleshoot "why didn't I get alerted?"
- Document alert notification policies


**How alert rules work:** Alert triggers → Rules evaluated in priority order → First matching rule wins → Routes alert to that rule's escalation chain → Escalation chain notifies recipients 

**Common alert rule patterns:** 
- **Priority 1 (Critical Production):** IF resource/device in "Production" group AND severity = critical → Route to "Critical On-Call" escalation chain 
- **Priority 2 (Database Team):** IF datasource contains "MySQL" OR "PostgreSQL" → Route to "Database Team" escalation chain 
- **Priority 3 (Business Hours):** IF severity = warning → Route to "Business Hours Email" chain (no pages) 
- **Priority 99 (Catch-All):** IF any alert not matched above → Route to "Default NOC" escalation chain 

**Use cases:** 
- "Who gets paged for production CPU alerts?" → Find rule matching prod resources/devices+ CPU datasource 
- "Update team notifications" → Modify alert rule to route to different escalation chain 
- "Stop getting low-priority pages" → Check which rule routes those alerts, adjust severity or chain 

**Critical for notification troubleshooting:** If alerts aren't reaching people, check:
- Does alert match any rule?
- Is matched rule enabled?
- Is escalation chain configured correctly?


**Important:** A negative "total" value in the response indicates incomplete results. Use pagination (size/offset parameters) or set autoPaginate: true to retrieve all items. 

**Related tools:** "get\_alert\_rule" (detailed conditions), "list\_escalation\_chains" (destination chains), "update\_alert\_rule" (modify routing). |
| `list_alerts` | List active alerts in LogicMonitor (LM) monitoring. 

**Returns:** Array of alerts with: id (alertId), severity (critical/error/warning), resource name, datasource, datapoint, alert message, start time (startEpoch), acknowledgement status (acked), alert rule. 

**When to use:** 
- Get all critical production alerts
- Find unacknowledged alerts needing attention
- Monitor specific service health
- Check CPU/memory alerts
- Generate alert reports

**Two search modes:** 
- **Simple search:** Use query parameter with free text (e.g., query:"prod-web-01") - searches by resource/device name (monitorObjectName field)
- **Advanced filtering:** Use filter parameter with LM filter syntax (e.g., filter:"severity:critical,acked:false") for precise control

**Common filter patterns:** 
- Critical alerts: filter:"severity:critical"
- Unacknowledged: filter:"acked:false"
- Specific device: filter:"monitorObjectName\~\*prod-web-01\*"
- CPU alerts: filter:"resourceTemplateName\~\*CPU\*"
- Recent alerts: filter:"startEpoch>1730851200" (epoch seconds)
- Combined: filter:"severity:critical,acked:false" (AND logic)

**Query vs Filter:** 
- query: Simple text search by resource/device name only (e.g., query:"production", query:"k8s-cluster")
- filter: Precise LM filter syntax with any alert field. Use for severity, acked status, etc.
- If both provided, query is converted to filter and combined with provided filter using AND logic

**Important:** Alert API does NOT support OR operator (||). Use comma for AND only. For complex queries, make multiple calls. 

**Important:** A negative "total" value in the response indicates incomplete results. Use pagination (size/offset parameters) or set autoPaginate: true to retrieve all items. 

**Related tools:** "get\_alert" (full details), "acknowledge\_alert" (acknowledge), "add\_alert\_note" (add notes), "generate\_alert\_link" (get URL). |
| `list_api_tokens` | List API tokens for a specific user in LogicMonitor (LM) monitoring. 

**Returns:** Array of API tokens for specified user with: id, note (description), created date, last used date, status (active/inactive), access ID, roles inherited from user. 

**What are API tokens:** Authentication credentials for LogicMonitor REST API. Alternative to username/password for programmatic access. Each token inherits permissions from its user. 

**When to use:** 
- Audit API access per user
- Find unused/stale tokens for security cleanup
- Check last usage time
- Inventory API integrations
- Before creating new token (check if existing one available)

**Security considerations:** 
- Each token has Access ID and Access Key (like username/password for API)
- Token inherits all permissions from user (if user is admin, token has admin rights)
- Tokens never expire automatically (must be manually revoked)
- Last used date helps identify unused tokens that should be removed

**Common use cases:** 
- **Security audit:** "Find all API tokens, check last usage, remove stale ones"
- **Integration tracking:** "Which integrations are using this user's tokens?"
- **Access review:** "What API access does this user have?"
- **Token rotation:** "List all tokens before rotating credentials"

**Best practices:** 
- Create service accounts (dedicated users) for API integrations instead of personal user tokens
- Add descriptive notes to tokens (e.g., "Terraform automation", "Grafana integration")
- Regularly audit and remove unused tokens (check lastUsedOn timestamp)
- Use least-privilege: Create users with minimal required permissions, then create tokens for those users

**Security workflow:** 
- List all users with "list\_users"
- For each user, use this tool to check their API tokens
- Review lastUsedOn - if >90 days, consider revoking
- Check note field to understand token purpose

**Workflow:** Use this tool with userId from "list\_users" to audit that user's API access. 

**Important:** A negative "total" value in the response indicates incomplete results. Use pagination (size/offset parameters) or set autoPaginate: true to retrieve all items. 

**Related tools:** "list\_users" (find userId), "create\_api\_token" (generate new), "delete\_api\_token" (revoke access). |
| `list_audit_logs` | List audit logs in LogicMonitor (LM) monitoring for compliance and security auditing. 

**Returns:** Array of audit log entries with: id, username, IP address, timestamp (happenedOn in epoch SECONDS), description of action performed, sessionId. 

**When to use:** 
- Investigate changes: "Who deleted this resource/device?" → filter:"description~\*Delete\*,description~\*device\*"
- Track user activity: "What did john.doe do today?" → filter:"username:john.doe,happenedOn>1730851200"
- Monitor API usage: Find actions performed via API tokens
- Compliance audits: Export log history for specific time periods
- Security investigation: Track login attempts, IP addresses, suspicious activities
- Troubleshooting: "Who changed this alert rule?" → filter:"description~\*AlertRule\*"

**Two search modes:** 
- **Simple search:** Use query parameter with free text (e.g., query:"john.doe", query:"device") - searches across username, description, and IP fields
- **Advanced filtering:** Use filter parameter with LM filter syntax (e.g., filter:"username:admin,happenedOn>1640995200") for precise control

**Common filter patterns:** 
- By user: filter:"username:john.doe"
- By time: filter:"happenedOn>1640995200" (IMPORTANT: epoch SECONDS, not milliseconds!)
- By action type: filter:"description~\*Create\*" or filter:"description~\*Delete\*" or filter:"description~\*Update\*"
- By resource: filter:"description~\*device\*" or filter:"description~\*dashboard\*"
- By IP: filter:"ip:192.168.1.100"
- Combined (AND): filter:"username:admin,happenedOn>1640995200,description~\*device\*"

**Query vs Filter:** 
- query: Simple text search across username, description, IP (OR logic). Use for quick lookups: query:"john.doe", query:"device"
- filter: Precise LM filter syntax with any field. Use for time ranges, exact matches: filter:"happenedOn>1640995200"
- If both provided, query is converted to filter and combined with provided filter using AND logic

**Critical notes:** 
- Time uses epoch SECONDS (not milliseconds like other LM APIs)
- Cannot use OR operator (||) in audit logs, only AND (comma)
- Use autoPaginate:true for complete history (may take time for large datasets)

**Web UI access:** https://test.logicmonitor.com/santaba/uiv4/settings/access-logs (Settings → Audit Logs) 

**Important:** A negative "total" value in the response indicates incomplete results. Use pagination (size/offset parameters) or set autoPaginate: true to retrieve all items. 

**Related tools:** "get\_audit\_log" (details of specific entry). |
| `list_collector_groups` | List all collector groups (folders) in LogicMonitor (LM) monitoring. 

**Returns:** Array of collector groups with: id, name, parentId, full path, description, number of collectors, number of subgroups. 

**What are collector groups:** Organizational folders for collectors (monitoring agents), similar to resource/device groups. Used to categorize collectors by location, function, or customer. 

**When to use:**
- Browse collector organization
- Find group IDs for collector operations
- Understand collector deployment structure
- Navigate to specific collector folders


**Common organization patterns:** 
- By location: "US-West Collectors", "EU Collectors", "APAC Collectors" 
- By environment: "Production Collectors", "Dev/Test Collectors" 
- By customer: "Customer A Collectors", "Customer B Collectors" (MSP) 
- By datacenter: "DC1 Collectors", "DC2 Collectors", "AWS Collectors" 
- By function: "Network Collectors", "Server Collectors", "Cloud Collectors" 

**Use cases:** 
- Organize collectors by geographic region 
- Group collectors by customer or tenant 
- Separate production vs non-production collectors 
- Structure multi-datacenter collector deployments 

**Workflow:** Use this tool to browse hierarchy, then "list\_collectors" filtered by groupId to see collectors in specific folder. 

**Important:** A negative "total" value in the response indicates incomplete results. Use pagination (size/offset parameters) or set autoPaginate: true to retrieve all items. 

**Related tools:** "get\_collector\_group" (details), "list\_collectors" (collectors in group), "create\_collector\_group" (create folder). |
| `list_collector_versions` | List available collector versions in LogicMonitor (LM) monitoring. 

**Returns:** Array of collector versions with: version number, release date, stability level (GA/EA/RC), changelog summary, download size, platform support (Windows/Linux), mandatory/recommended flag. 

**What are collector versions:** Software releases for LogicMonitor collector agents. Collectors are installed on your infrastructure to gather monitoring data. Staying current ensures latest features, bug fixes, and security patches. 

**When to use:**
- Check for collector updates
- Review changelog before upgrading
- Find specific version for rollback
- Verify platform compatibility
- Plan maintenance windows for collector upgrades


**Version types:** 
- **GA (Generally Available):** Production-ready, stable, recommended 
- **EA (Early Adopter):** Beta, new features, use in non-production first 
- **RC (Release Candidate):** Pre-GA testing version 
- **Mandatory:** Critical security/bug fixes, upgrade required 

**Collector update workflow:** 1. Use this tool to check available versions 2. Review changelog for breaking changes 3. Test new version on non-production collector first 4. Use "get\_collector" to check current version on your collectors 5. Update collectors via LogicMonitor UI or API 6. Monitor collector health after upgrade 

**Version numbering:** Format is typically X.Y.Z (e.g., 34.100.0) where: 
- X = Major release (significant changes) 
- Y = Minor release (features, improvements) 
- Z = Patch release (bug fixes) 

**Best practices:** 
- Keep collectors within 2-3 versions of latest GA release 
- Subscribe to release notifications for critical updates 
- Test EA versions in lab before production 
- Upgrade during maintenance windows (may briefly interrupt monitoring) 
- Stagger upgrades (don't upgrade all collectors simultaneously) 

**Common scenarios:** 
- "Check if newer version available" → Compare latest version to your collectors 
- "Plan upgrade" → Review changelog, schedule maintenance 
- "Rollback needed" → Find previous stable version 
- "Platform migration" → Verify version supports new OS 

**Related tools:** "get\_collector" (check current version on collector), "list\_collectors" (find collectors to upgrade). |
| `list_collectors` | List all LogicMonitor (LM) monitoring collectors (monitoring agents). 

**Returns:** Array of collectors with: id, description (collector name), hostname, platform (Windows/Linux), status (alive/dead), build version, number of monitored resources/devices, last heartbeat time. 

**When to use:** 
- Check collector health status before adding resources/devices
- Find available collectors for new resource/device assignments
- Monitor collector capacity and load
- Identify offline/dead collectors

**What are collectors:** Lightweight agents installed on-premise or in cloud that collect metrics from resources/devices. Each resource/device must be assigned to one collector. 

**Common filter patterns:** 
- Alive collectors: filter:"status:alive"
- By platform: filter:"platform:Linux" or filter:"platform:Windows"
- By name: filter:"description\~\*prod\*"
- Low capacity: filter:"numberOfHosts<100"

**Before creating resources/devices:** Use this tool to find collectorId for the "preferredCollectorId" parameter in "create\_resource". 

**Important:** A negative "total" value in the response indicates incomplete results. Use pagination (size/offset parameters) or set autoPaginate: true to retrieve all items. 

**Related tools:** "get\_collector" (details), "list\_collector\_groups" (browse groups), "list\_collector\_versions" (check updates). |
| `list_configsources` | List all ConfigSources in LogicMonitor (LM) monitoring. 

**Returns:** Array of ConfigSources with: id, name, displayName, description, appliesTo logic, collection method. 

**What are ConfigSources:** Track configuration file changes for compliance and change management. Similar to datasources, but for configs instead of metrics. Alert when configs change unexpectedly. 

**When to use:** 
- Find ConfigSource for specific resource/device type (e.g., Cisco\_IOS\_Config)
- Discover what configs are being tracked
- Get ConfigSource IDs for API operations
- Audit configuration monitoring coverage

**What configs can be tracked:** 
- Network resources/devices: Router configs, switch configs, firewall rules
- Linux: /etc files, app configs, SSH authorized_keys
- Windows: Registry keys, security policies
- Cloud: Security groups, IAM policies

**Use cases:** 
- Compliance: "Alert when firewall rules change"
- Change management: "Who modified this router config?"
- Rollback: Compare current config to previous version
- Audit: "Show all config changes in last 30 days"

**Common ConfigSources:** 
- Cisco\_IOS_Config: Cisco router/switch configs
- F5\_LTM\_Config: F5 load balancer configs
- Palo\_Alto\_Config: Palo Alto firewall rules
- Linux\_Config\_Files: Monitor /etc files

**Important:** A negative "total" value in the response indicates incomplete results. Use pagination (size/offset parameters) or set autoPaginate: true to retrieve all items. 

**Related tools:** "get\_configsource" (details), "list\_device\_configs" (see configs for device). |
| `list_dashboard_groups` | List all dashboard groups (folders) in LogicMonitor (LM) monitoring. 

**Returns:** Array of dashboard groups with: id, name, parentId, full path, description, number of dashboards, number of subgroups, owner. 

**What are dashboard groups:** Organizational folders for dashboards, like directories in a file system. Used to organize dashboards by team, function, or application. 

**When to use:** 
- Browse dashboard organization before creating/moving dashboards
- Find group IDs for dashboard operations
- Understand dashboard hierarchy
- Navigate to specific dashboard folders

**Common organization patterns:** 
- By team: "Platform Team", "Database Team", "Network Team"
- By environment: "Production", "Staging", "Development"
- By application: "Web App", "API Services", "Background Jobs"
- By cloud provider: "AWS Dashboards", "Azure Dashboards"

**Workflow:** Use this tool to browse hierarchy, then "list\_dashboards" filtered by groupId to see dashboards in specific folder. 

**Important:** A negative "total" value in the response indicates incomplete results. Use pagination (size/offset parameters) or set autoPaginate: true to retrieve all items. 

**Related tools:** "get\_dashboard\_group" (details), "list\_dashboards" (dashboards in group), "create\_dashboard\_group" (create folder). |
| `list_dashboards` | List all dashboards in LogicMonitor (LM) monitoring. 

**Returns:** Array of dashboards with: id, name, description, groupId, groupName, widget count, owner. 

**When to use:** 
- Find AWS/Azure/infrastructure dashboards
- Discover available pre-built dashboards
- Get dashboard IDs for generating links
- List dashboards in specific group

**Common filter patterns:** 
- By name: filter:"name\~\*AWS\*" (find all AWS dashboards)
- By group: filter:"groupId:5" or filter:"groupName\~\*Cloud\*"
- By owner: filter:"owner:john.doe"

**Next step:** Use "generate\_dashboard\_link" with the dashboard ID to get the full clickable URL for sharing. 

**Tip:** Dashboards are organized in groups. Use "list\_dashboard\_groups" to browse the hierarchy. 

**Important:** A negative "total" value in the response indicates incomplete results. Use pagination (size/offset parameters) or set autoPaginate: true to retrieve all items. 

**Related tools:** "get\_dashboard" (details), "generate\_dashboard\_link" (get URL), "list\_dashboard\_groups" (browse hierarchy). |
| `list_datasources` | List all available datasources in LogicMonitor (LM) monitoring. 

**Returns:** Array of datasources with: id, name, displayName, description, appliesTo (which resource/device it monitors), collection method, datapoints/metrics collected. 

**What are datasources:** Templates that define WHAT to monitor (e.g., CPU, memory, disk), HOW to collect it (SNMP, WMI, API), and WHEN to alert. LogicMonitor has 2000+ pre-built datasources for common technologies. 

**When to use:** 
- Find datasource for specific technology (e.g., "AWS\_EC2", "VMware\_vCenter")
- Discover what can be monitored
- Get datasource IDs for API operations
- Browse monitoring capabilities

**Common filter patterns:** 
- By name: filter:"name\~\*CPU\*" or filter:"displayName\~\*Memory\*"
- Cloud providers: filter:"name\~\*AWS\*" or filter:"name\~\*Azure\*"
- Database: filter:"name\~\*MySQL\*" or filter:"name\~\*SQL\_Server\*"
- Network: filter:"name\~\*Cisco\*" or filter:"name\~\*SNMP\*"

**Examples:** AWS\_EC2 (monitors EC2 instances), SNMP\_Network\_Interfaces (network stats), WinCPU (Windows CPU), Linux\_SSH (Linux via SSH). 

**Important:** A negative "total" value in the response indicates incomplete results. Use pagination (size/offset parameters) or set autoPaginate: true to retrieve all items. 

**Related tools:** "get\_datasource" (details), "list\_resource\_datasources" (see what's applied to specific resource/device). |
| `list_escalation_chains` | List all escalation chains in LogicMonitor (LM) monitoring. 

**Returns:** Array of escalation chains with: id, name, description, escalation stages, recipients at each stage, timing/delays, enabled status. 

**What are escalation chains:** Define HOW and WHO gets notified when alerts trigger. Multi-stage notification workflows: Stage 1 (notify team lead immediately) → Stage 2 (if still open after 15 min, notify manager) → Stage 3 (if still open after 30 min, page director). 

**When to use:**
- Audit notification routing
- Find escalation chain IDs for alert rule configuration
- Review who gets notified for critical alerts
- Verify on-call escalation paths


**How escalation chains work:** Alert triggers → Alert Rule matches → Routes to Escalation Chain → Stage 1 notifies immediately → Wait X minutes → If still alerting, Stage 2 notifies → Repeat through stages 

**Common escalation patterns:** 
- **Critical Production:** Stage 1: On-call engineer (0 min) → Stage 2: Team lead (15 min) → Stage 3: Engineering manager (30 min) 
- **Standard:** Stage 1: Team email (0 min) → Stage 2: PagerDuty (30 min) 
- **Business Hours Only:** Stage 1: Team Slack (0 min, 8am-6pm only) 

**Use cases:** 
- "Who gets paged for critical database alerts?" → Check escalation chain 
- "Why didn't I get notified?" → Verify you're in the escalation chain 
- "Update on-call rotation" → Modify escalation chain recipients 

**Important:** A negative "total" value in the response indicates incomplete results. Use pagination (size/offset parameters) or set autoPaginate: true to retrieve all items. 

**Related tools:** "get\_escalation\_chain" (detailed stages), "list\_alert\_rules" (see which rules use chain), "list\_recipients" (available notification targets). |
| `list_eventsources` | List all EventSources in LogicMonitor (LM) monitoring. 

**Returns:** Array of EventSources with: id, name, displayName, description, appliesTo logic, event collection method. 

**What are EventSources:** Collect and process event data (logs, Windows events, syslog, traps). Different from DataSources (metrics) and ConfigSources (configs). Used for log monitoring and event correlation. 

**When to use:**
- Find EventSource for log monitoring
- Discover what events are being collected
- Get EventSource IDs for operations
- Audit event monitoring coverage


**Event types collected:** 
- Windows Event Logs: Application, Security, System logs 
- Syslog: Linux/Unix system logs, network resource/device logs 
- SNMP Traps: Network resource/device alerts and notifications 
- Application logs: Custom app logs, web server logs 
- Cloud events: CloudWatch logs, Azure events 

**Common EventSources:** 
- Windows\_Application\_EventLog: Windows application events 
- Windows\_Security\_EventLog: Security/audit logs 
- Linux\_Syslog: Linux system logs via syslog 
- SNMP\_Traps: Network resource/device SNMP traps 
- VMware\_Events: vCenter events 

**Use cases:** 
- Monitor Windows failed login attempts 
- Alert on ERROR/CRITICAL in application logs 
- Collect network resource/device syslog for troubleshooting 
- Track security events for compliance 

**Important:** A negative "total" value in the response indicates incomplete results. Use pagination (size/offset parameters) or set autoPaginate: true to retrieve all items. 

**Related tools:** "get\_eventsource" (details), "list\_device\_eventsources" (events for device). |
| `list_integrations` | List all third-party integrations configured in LogicMonitor (LM) monitoring. 

**Returns:** Array of integrations with: id, name, type (Slack/PagerDuty/ServiceNow/Jira/etc), status (active/inactive), configuration summary, authentication status. 

**What are integrations:** Connections to external platforms for alert notifications, ticket creation, chat messages, incident management. Extend LogicMonitor alerting beyond email/SMS. 

**When to use:**
- Find integration IDs for escalation chains
- Verify integrations are working
- Audit external connections
- Check authentication status
- Review available integration options


**Popular integrations:** 

**Incident Management:** 
- **PagerDuty:** Page on-call engineers for critical alerts 
- **Opsgenie:** Alternative incident management and on-call scheduling 
- **VictorOps (Splunk On-Call):** Alert routing and escalation 

**Ticketing:** 
- **ServiceNow:** Auto-create incidents for alerts 
- **Jira:** Create tickets for infrastructure issues 
- **Zendesk:** Customer-facing service desk integration 

**Collaboration:** 
- **Slack:** Post alerts to channels, interactive notifications 
- **Microsoft Teams:** Teams channel notifications 
- **Mattermost:** Self-hosted chat notifications 

**Workflow & Automation:** 
- **Webhooks:** Custom integrations to any HTTP endpoint 
- **API:** Programmatic integration for custom workflows 

**Use cases:** 
- "Post critical production alerts to #incidents Slack channel" 
- "Auto-create ServiceNow ticket for every critical alert" 
- "Page PagerDuty when datacenter resource/device go offline" 
- "Update Jira epic when deployment causes alerts" 

**Integration status:** 
- Active: Integration configured and working 
- Inactive: Disabled or authentication failed 
- Test: Verify integration by triggering test notification 

**Workflow:** Use this tool to find integrations, then use in escalation chains or as webhook recipients for alert delivery. 

**Important:** A negative "total" value in the response indicates incomplete results. Use pagination (size/offset parameters) or set autoPaginate: true to retrieve all items. 

**Related tools:** "get\_integration" (configuration details), "test\_integration" (verify working), "list\_escalation\_chains" (see usage). |
| `list_netscans` | List all network discovery scans (NetScans) in LogicMonitor (LM) monitoring. 

**Returns:** Array of netscans with: id, name, description, scan method (nmap/script/ICMP/SNMP), schedule, target networks (IP ranges/subnets), collector, last run time, resource/device discovered. 

**What are netscans:** Automated network discovery that finds resource/device on your network and adds them to monitoring. Instead of manually adding resource/device one-by-one, netscan automatically discovers and onboards resource/device based on IP ranges or subnets. 

**When to use:**
- Audit existing discovery configurations
- Check which networks are being scanned
- Review netscan schedules
- Troubleshoot why resource/device not auto-discovered
- Find netscan IDs for modifications


**How netscans work:** Scheduled job → Scan network range (e.g., 192.168.1.0/24) → Find live resource/device → Check if already monitored → If new, add to LogicMonitor → Apply resource/device properties and datasources → Begin monitoring 

**NetScan methods:** 
- **nmap:** Network mapper scan (comprehensive, detects OS, ports, services) 
- **ICMP Ping:** Simple ping sweep (fastest, basic reachability) 
- **SNMP Walk:** Query SNMP-enabled resource/device (network gear, servers with SNMP) 
- **Script:** Custom discovery logic (cloud APIs, CMDBs, etc.) 
- **AWS/Azure/GCP:** Cloud auto-discovery via APIs 

**Common use cases:** 
- **Data center discovery:** Scan 10.0.0.0/16 network, auto-add all servers 
- **Cloud auto-discovery:** Scan AWS account, add all EC2 instances daily 
- **Branch office monitoring:** Scan remote office subnets, discover network resource/device 
- **Dynamic infrastructure:** Auto-discover containers, VMs as they spin up 

**Example NetScan configurations:** 
- "Production Servers" - Scan 192.168.1.0/24 every 6 hours via nmap 
- "AWS EC2 Discovery" - Query AWS API every hour for new instances 
- "Network resources/Devices" - SNMP walk 10.0.0.0/8 daily for routers/switches 

**Workflow:** Use this tool to review netscans, then "get\_netscan" for detailed configuration including filters and resource/device properties. 

**Important:** A negative "total" value in the response indicates incomplete results. Use pagination (size/offset parameters) or set autoPaginate: true to retrieve all items. 

**Related tools:** "get\_netscan" (configuration details), "create\_netscan" (set up auto-discovery), "run\_netscan" (trigger manual scan). |
| `list_opsnotes` | List all operational notes (OpsNotes) in LogicMonitor (LM) monitoring. 

**Returns:** Array of OpsNotes with: id, note text, timestamp (epoch), who created it, tags, scope (applies to which resources/devices/groups), related SDTs. 

**What are OpsNotes:** Timestamped operational annotations displayed on graphs and dashboards. Document changes, deployments, maintenance, incidents - anything that might affect metrics. Appear as vertical lines on metric graphs at the time they occurred. 

**When to use:**
- Correlate metric changes with operational events
- Document deployments/changes
- Create timeline of incidents and responses
- Track maintenance activities
- Generate operational reports


**Use cases and examples:** 

**Deployments:** 
- "Deployed v2.5.0 to production" (explains CPU spike at deploy time) 
- "Database schema migration" (explains slow queries during migration) 

**Incidents:** 
- "Customer reported slow load times - investigating" 
- "Found memory leak, restarting services" 
- "Incident resolved - bad cache configuration" 

**Maintenance:** 
- "Scaled from 10 to 15 instances" 
- "Updated SSL certificates" 
- "Cleared old logs, freed 500GB disk" 

**Benefits:** 
- **Troubleshooting:** "Latency increased at 2pm" → Check OpsNotes: "Deploy happened at 2pm" 
- **Correlation:** Understand cause of metric anomalies 
- **Documentation:** Automatic operational timeline 
- **Communication:** Share what happened with team 

**Common filter patterns:** 
- By time: filter:"happenedOn>1730851200" (recent notes) 
- By tags: filter:"tags~*deployment*" 
- By device: filter:"monitorObjectName~*prod-web*" 

**Displayed on:** Graphs, dashboards, resource/device pages - visible wherever metrics are shown. 

**Important:** A negative "total" value in the response indicates incomplete results. Use pagination (size/offset parameters) or set autoPaginate: true to retrieve all items. 

**Related tools:** "get\_opsnote" (details), "create\_opsnote" (add new), "create\_device\_sdt" (maintenance windows). |
| `list_recipient_groups` | List all recipient groups in LogicMonitor (LM) monitoring. 

**Returns:** Array of recipient groups with: id, name, description, member count, recipients list. 

**What are recipient groups:** Collections of recipients treated as a single notification target. Simplify escalation chains by notifying entire teams at once. Example: "Database Team" group contains 5 team members - notify group = notify all 5. 

**When to use:**
- Find group IDs for escalation chains
- Audit team notification lists
- Review group membership before changes
- Simplify notification management


**Benefits over individual recipients:** 
- **Easier management:** Update team once, applies to all escalation chains using that group 
- **Team notifications:** Notify entire team simultaneously 
- **Organized:** Group by function (DB team, Network team, On-call rotation) 

**Common recipient groups:** 
- "On-Call Engineers" - Current on-call rotation members 
- "Database Team" - All database administrators 
- "Network Operations" - NOC team members 
- "Management" - For escalation to leadership 

**Use cases:** 
- "Notify entire team for critical alerts" → Use group instead of 5 individual recipients 
- "Rotate on-call" → Update group members without touching escalation chains 
- "Add new team member" → Add to group, automatically included in alerts 

**Workflow:** Use this tool to find groups, then use in escalation chains to notify multiple people at once. 

**Important:** A negative "total" value in the response indicates incomplete results. Use pagination (size/offset parameters) or set autoPaginate: true to retrieve all items. 

**Related tools:** "get\_recipient\_group" (details), "list\_recipients" (individual members), "list\_escalation\_chains" (see usage). |
| `list_recipients` | List all alert recipients (individual notification targets) in LogicMonitor (LM) monitoring. 

**Returns:** Array of recipients with: id, type (email/SMS/webhook), contact information, method (email address, phone number, webhook URL), name, status. 

**What are recipients:** Individual notification endpoints used in escalation chains. Can be: email addresses, SMS/phone numbers, webhook URLs, or integration endpoints (Slack, PagerDuty, etc.). 

**When to use:**
- Find recipient IDs for escalation chain configuration
- Audit who can receive alerts
- Verify contact information is current
- Review notification endpoints before updating escalation chains


**Recipient types explained:** 
- **Email:** Email address (e.g., oncall@company.com, john.doe@company.com) 
- **SMS:** Mobile phone number (e.g., +1-555-123-4567) 
- **Voice:** Phone number for voice calls 
- **Arbitrary:** Custom webhooks for external integrations 

**Common use cases:** 
- "Who can receive critical production alerts?" → List recipients used in escalation chains 
- "Update on-call phone number" → Find recipient by name, update contact info 
- "Add new team member to alerts" → Create recipient, add to escalation chain 
- "Remove former employee" → Find and delete recipient 

**Recipients vs Recipient Groups:** 
- Recipients: Individual targets (one email, one phone) 
- Recipient Groups: Collections of recipients (notify entire team at once) 

**Workflow:** Use this tool to find available recipients, then use in "create\_escalation\_chain" or "update\_escalation\_chain" to set up notifications. 

**Important:** A negative "total" value in the response indicates incomplete results. Use pagination (size/offset parameters) or set autoPaginate: true to retrieve all items. 

**Related tools:** "get\_recipient" (details), "list\_recipient\_groups" (group management), "list\_escalation\_chains" (see who gets notified). |
| `list_report_groups` | List all report groups (folders) in LogicMonitor (LM) monitoring. 

**Returns:** Array of report groups with: id, name, parentId, full path, description, number of reports, number of subgroups. 

**What are report groups:** Organizational folders for reports, like directories for files. Used to categorize reports by audience, frequency, purpose, or department. 

**When to use:**
- Browse report organization before creating reports
- Find group IDs for report operations
- Understand report hierarchy
- Navigate to specific report folders


**Common organization patterns:** 
- By audience: "Executive Reports", "Operations Reports", "Customer Reports" 
- By frequency: "Daily Reports", "Weekly Reports", "Monthly Reports" 
- By department: "IT Reports", "Finance Reports", "Compliance Reports" 
- By type: "SLA Reports", "Capacity Reports", "Alert Summary Reports" 

**Use cases:** 
- Organize reports for different stakeholders 
- Group compliance/audit reports separately 
- Separate internal vs customer-facing reports 
- Structure reports by delivery schedule 

**Workflow:** Use this tool to browse hierarchy, then "list\_reports" filtered by groupId to see reports in specific folder. 

**Important:** A negative "total" value in the response indicates incomplete results. Use pagination (size/offset parameters) or set autoPaginate: true to retrieve all items. 

**Related tools:** "get\_report\_group" (details), "list\_reports" (reports in group), "create\_report\_group" (create folder). |
| `list_reports` | List all reports (scheduled and on-demand) in LogicMonitor (LM) monitoring. 

**Returns:** Array of reports with: id, name, type (alert/availability/capacity/performance), description, schedule, recipients, format (PDF/HTML/CSV), last run time. 

**What are reports:** Scheduled or on-demand documents summarizing monitoring data. Generate PDFs, HTML, or CSV files with metrics, alerts, availability statistics, capacity planning data. Automatically email to stakeholders. 

**When to use:** 
- Find existing reports before creating duplicates
- Review report schedules
- Check who receives reports
- Audit reporting configuration

**Report types:** 
- **Alert Reports:** Summary of alerts over time period (count by severity, MTTR, top alerting resources/devices)
- **Availability Reports:** Uptime statistics, SLA compliance, outage summaries
- **Capacity Planning:** Disk growth trends, CPU/memory usage over time, forecasting
- **Performance Reports:** Metric trends, top consumers, performance baselines
- **Custom Reports:** User-defined queries and visualizations

**Common use cases:** 
- **Executive summaries:** Monthly availability report to leadership
- **SLA reporting:** Prove 99.9% uptime to customers
- **Capacity planning:** Forecast when to add storage/servers
- **Compliance:** Document monitoring coverage and alert response
- **Billing:** Usage reports for chargebacks

**Report schedules:** 
- Daily: 8am delivery for NOC shift handoff
- Weekly: Monday morning management briefing
- Monthly: End-of-month SLA reports
- Quarterly: Capacity planning reviews
- On-demand: Generate for specific incidents/audits

**Workflow:** Use this tool to find reports, then "get\_report" for details, or "generate\_report" to run on-demand. 

**Important:** A negative "total" value in the response indicates incomplete results. Use pagination (size/offset parameters) or set autoPaginate: true to retrieve all items. 

**Related tools:** "get\_report" (details), "list\_report\_groups" (organization), "generate\_report" (run now). |
| `list_resource_datasources` | List datasources applied to a specific resource/device in LogicMonitor (LM) monitoring. 

**Returns:** Array of datasources actively monitoring this resource/device with: id (deviceDataSourceId), dataSourceName, dataSourceDisplayName, status, alert status, instance count, last poll time. 

**When to use:**
- See what's being monitored on a resource/device
- Verify datasource is collecting data
- Get deviceDataSourceId for metric retrieval
- Troubleshoot missing data
- Check datasource health


**What you discover:** 
- Which datasources are active (e.g., WinCPU, WinMemory, SNMP_Network_Interfaces) 
- How many instances per datasource (e.g., 3 disks, 4 network interfaces) 
- Collection status: Collecting data vs errors 
- Alert status: Any active alerts from this datasource 

**This is step 1 for getting metrics:** **Complete workflow to retrieve metric data:** 1. Use this tool → get deviceDataSourceId for datasource you want (e.g., WinCPU) 2. Use "list\_device\_instances" → get instanceId for specific instance 3. Use "get\_device\_instance\_data" → get actual metric values 

**Troubleshooting use cases:** 
- "Why no CPU data?" → Check if WinCPU datasource is applied and collecting 
- "Find disk datasource" → Look for datasource with "disk" or "volume" in name 
- "Check datasource errors" → Review status field for error messages 

**Important:** A negative "total" value in the response indicates incomplete results. Use pagination (size/offset parameters) or set autoPaginate: true to retrieve all items. 

**Related tools:** "list\_device\_instances" (next step), "get\_device\_instance\_data" (get metrics), "update\_device\_datasource" (enable/disable). |
| `list_resource_group_properties` | List all custom properties for a specific resource/device group in LogicMonitor (LM) monitoring. Properties set at group level are inherited by all resource/device in the group. 

**Returns:** Array of properties with: name, value, type (custom vs system), and inheritance source. 

**When to use:**
- Review properties before bulk updates
- Audit credentials/settings applied to resource/device group
- Verify property inheritance from parent groups
- Check which properties resource/device will inherit when added to group
- Document group configuration


**What are group properties:** Key-value pairs set at group level that ALL resource/device in the group inherit. Common uses: credentials (SSH/SNMP), environment tags, owner/team info, monitoring settings. 

**Property inheritance:** 
- Properties set on group apply to ALL resource/device in group 
- Child groups inherit from parent groups 
- Device-level properties override group properties 
- Used by datasource "appliesTo" logic and authentication 

**Common group properties:** 
- **Credentials:** ssh.user, ssh.pass, snmp.community, wmi.user, wmi.pass 
- **Tags:** env (production/staging), location (datacenter), owner (team name) 
- **Business metadata:** cost.center, sla.tier, compliance.level 
- **Monitoring config:** polling.interval, alert.threshold.multiplier 

**Use cases:** 
- Audit credentials: Check which credentials are configured for group 
- Before bulk update: See current values before changing 
- Troubleshoot authentication: Verify credentials applied to resource/device 
- Document configuration: Export group settings 

**Workflow:** Use "list\_resource\_groups" to find groupId, then use this tool to see properties, then "update\_device\_group\_property" to modify. 

**Important:** A negative "total" value in the response indicates incomplete results. Use pagination (size/offset parameters) or set autoPaginate: true to retrieve all items. 

**Related tools:** "update\_device\_group\_property" (modify property), "get\_resource\_group" (group details), "list\_device\_properties" (device-level properties). |
| `list_resource_groups` | List all resource/device groups (folders) in LogicMonitor (LM) monitoring. 

**Returns:** Array of groups with: id, name, parentId, full path, description, number of resources/devices, number of subgroups, custom properties. 

**What are groups:** Organizational folders for resources/devices, like directories in a file system. Used to organize by location, environment, customer, or any logical structure. 

**When to use:** 
- Browse resource/device organization
- Find group IDs for resource/device creation/assignment
- Understand resource/device hierarchy
- Get group IDs for group-level operations (properties, SDT)

**Common use cases:** 
- Geographic: "US-West", "EU-Central", "APAC"
- Environment: "Production", "Staging", "Development"
- Customer: "Customer-A", "Customer-B" (for MSPs)
- Function: "Web Servers", "Database Servers", "Network resources/Devices"

**Common filter patterns:** 
- By name: filter:"name\~\*Production\*"
- Root groups: filter:"parentId:1"
- Non-empty: filter:"numOfDirectDevices>0"

**Groups inherit properties:** Custom properties set on group are inherited by all resource/device in that group (useful for credentials, location tags). 

**Important:** A negative "total" value in the response indicates incomplete results. Use pagination (size/offset parameters) or set autoPaginate: true to retrieve all items. 

**Related tools:** "get\_resource\_group" (details), "create\_resource\_group" (create new), "list\_resource\_group\_properties" (group properties). |
| `list_resource_instances` | List instances of a datasource on a specific resource/device in LogicMonitor (LM) monitoring. 

**Returns:** Array of instances with: id, name, displayName, description, status, alert status, last collection time. 

**What are instances:** Individual components monitored by a datasource. Examples: individual disks (C:, D:, E:), network interfaces (eth0, eth1), database tables, processes. 

**When to use:** 
- List all disks on a server before getting disk metrics
- Find specific network interface for bandwidth data
- Discover what instances are being monitored
- Get instance IDs for metric retrieval

**Example workflow:** Device "web-server-01" has datasource "WinVolumeUsage-" → instances: C:, D:, E: (each disk is an instance) Device "router-01" has datasource "SNMP\_Network\_Interfaces" → instances: GigabitEthernet0/1, GigabitEthernet0/2 (each interface is an instance) 

**Complete workflow to get metrics:** 
- Use "list\_resource\_datasources" to get deviceDataSourceId
- Use this tool to list instances and get instanceId
- Use "get\_resource\_instance\_data" with instanceId to get actual metrics

**Important:** A negative "total" value in the response indicates incomplete results. Use pagination (size/offset parameters) or set autoPaginate: true to retrieve all items. 

**Related tools:** "list\_resource\_datasources" (first step), "get\_resource\_instance\_data" (get metrics). |
| `list_resource_properties` | List all custom properties (system and user-defined) for a specific resource/device in LogicMonitor (LM) monitoring. 

**Returns:** Array of properties with: name, value, source (device-level vs inherited from group), type (system vs custom). 

**When to use:** 
- Review resource/device configuration
- Check credentials/authentication settings
- See inherited vs device-specific properties
- Troubleshoot datasource applies logic
- Audit resource/device metadata

**Property types:** 

**System properties (auto-populated by LogicMonitor):** 
- system.hostname: Device hostname
- system.devicetype: Device category (server, network, cloud)
- system.ips: IP addresses
- system.categories: Auto-detected technologies (e.g., "AWS/EC2")

**Custom properties (user-defined):** 
- Credentials: ssh.user, snmp.community, wmi.user
- Tags: env (prod/staging), owner (team name), location
- Integration IDs: servicenow.ci_id, jira.project
- Business metadata: cost.center, sla.tier, backup.policy

**Property inheritance:** Properties can be set at: Device level (highest priority) → Group level → Parent group (inherited). 

**Datasource appliesTo logic uses properties:** Many datasources check properties to decide if they should monitor device. Example: AWS\_EC2 datasource checks if resource/device has "aws.resourcetype=ec2" property. 

**Workflow:** Use "list\_resources" to find deviceId, then use this tool to see all properties including inherited ones. 

**Important:** A negative "total" value in the response indicates incomplete results. Use pagination (size/offset parameters) or set autoPaginate: true to retrieve all items. 

**Related tools:** "update\_device\_property" (modify), "get\_resource" (see summary), "list\_datasources" (see how properties affect monitoring). |
| `list_resources` | List all monitored resources/devices in LogicMonitor (LM) monitoring. 

**Returns:** Array of resource/device with: id, displayName, name (IP/hostname), hostStatus (dead/alive/unknown), preferredCollectorId, deviceType, custom properties, group memberships. 

**When to use:** 
- Get inventory of all monitored resources/devices
- Find specific resource/device by name/IP/property
- Check resource/device health status
- Get resource/device IDs for other operations

**Two search modes:** 
- **Simple search:** Use query parameter with free text (e.g., query:"production", query:"web-server") - automatically searches displayName, description, and name fields
- **Advanced filtering:** Use filter parameter with LM filter syntax (e.g., filter:"hostStatus:alive,displayName~\*web\*") for precise control

**Common filter patterns:** 
- By name: filter:"displayName\~\*prod\*" (wildcard search) 
- By status: filter:"hostStatus:alive" or filter:"hostStatus:dead" 
- By type: filter:"systemProperties.name:system.devicetype,value:server" 
- By custom property: filter:"customProperties.name:company.team,customProperties.value:teamA" 
- By collector: filter:"preferredCollectorId:123" 
- Multiple conditions: filter:"hostStatus:alive,displayName\~\*web\*" (comma = AND) 

**Query vs Filter:** 
- query: Simplified search across displayName, description, name (OR logic). Use for quick lookups: query:"prod-web-01"
- filter: Precise LM filter syntax with any field. Use for complex conditions: filter:"hostStatus:alive,displayName~\*prod\*"
- If both provided, query is converted to filter and combined with provided filter using AND logic

**Important:** A negative "total" value in the response indicates incomplete results. Use pagination (size/offset parameters) or set autoPaginate: true to retrieve all items. 

**Performance tips:** Use autoPaginate:false for large environments (>1000 resources/devices) and paginate manually to avoid timeouts. 

**Related tools:** "get\_resource" (details), "generate\_resource\_link" (get UI link). |
| `list_roles` | List all roles (permission sets) in LogicMonitor (LM) monitoring. 

**Returns:** Array of roles with: id, name, description, custom flag, associated users count, permissions (view/manage/delete for resources/alerts/reports/settings). 

**What are roles:** Permission templates assigned to users. Control who can view/modify/delete resources, alerts, dashboards, settings. Essential for RBAC (role-based access control). 

**When to use:** 
- Discover available roles before creating users
- Audit permission structure
- Find role IDs for user assignment
- Compare custom vs built-in roles
- Compliance documentation

**Built-in roles (examples):** 
- administrator: Full access to everything
- readonly: View-only access to monitoring data
- manager: Manage resources/devices/alerts but not settings

**Custom roles:** Organizations create custom roles for specific needs (e.g., "database-team-role", "view-prod-only"). 

**Common use cases:** 
- "What roles exist?" → List all to see options
- "Who can delete resources/devices?" → Check which roles have delete permissions
- "Create read-only user" → Find "readonly" role ID for user creation

**Workflow:** Use this tool to discover roles, then "get\_role" for detailed permissions, then use in "create\_user" or "update\_user". 

**Important:** A negative "total" value in the response indicates incomplete results. Use pagination (size/offset parameters) or set autoPaginate: true to retrieve all items. 

**Related tools:** "get\_role" (detailed permissions), "list\_users" (see user assignments), "create\_user" (assign roles to new users). |
| `list_sdts` | List all Scheduled Down Times (SDTs) in LogicMonitor (LM) monitoring. 

**Returns:** Array of SDTs with: id, type (DeviceSDT/DeviceGroupSDT/etc), device/group name, start/end times, duration, comment, creator, status (active/scheduled/expired). 

**What are SDTs:** Maintenance windows that suppress alerting to prevent false alarms during planned work. No alerts are generated during SDT periods. 

**When to use:** 
- View active maintenance windows
- Check upcoming scheduled maintenance
- Verify SDT was created correctly
- Find SDTs to extend or cancel
- Audit who scheduled downtime

**Common filter patterns:** 
- Active now: filter:"isEffective:true"
- Future SDTs: filter:"startDateTime>{epoch}"
- By device: filter:"deviceDisplayName\~\*prod-web\*"
- One-time vs recurring: filter:"type:oneTime" or filter:"type:monthly"
- By creator: filter:"admin:john.doe"

**SDT types explained:** 
- DeviceSDT: All monitoring on specific resource/device
- DeviceGroupSDT: All resource/device in group
- DeviceDataSourceSDT: Specific datasource on resource/device
- DeviceDataSourceInstanceSDT: Specific instance only (e.g., C: drive)

**Best practice:** Always add meaningful comment explaining maintenance reason for audit trail. 

**Important:** A negative "total" value in the response indicates incomplete results. Use pagination (size/offset parameters) or set autoPaginate: true to retrieve all items. 

**Related tools:** "create\_resource\_sdt" (schedule maintenance), "delete\_sdt" (cancel maintenance), "get\_sdt" (details). |
| `list_service_groups` | List all service groups (folders) in LogicMonitor (LM) monitoring. 

**Returns:** Array of service groups with: id, name, parentId, full path, description, number of services, number of subgroups. 

**What are service groups:** Organizational folders for business services, similar to resource/device groups for resources/devices. Used to categorize services by business unit, region, customer, or application stack. 

**When to use:**
- Browse service organization before creating services
- Find group IDs for service operations
- Understand service hierarchy
- Navigate to specific service folders


**Common organization patterns:** 
- By business unit: "E-Commerce", "Marketing Platform", "Internal IT" 
- By customer: "Customer A Services", "Customer B Services" (MSP environments) 
- By region: "APAC Services", "EMEA Services", "Americas Services" 
- By tier: "Tier 1 Critical", "Tier 2 Standard", "Tier 3 Best Effort" 

**Use cases:** 
- Organize services for different stakeholders 
- Group services by SLA tiers 
- Separate internal vs customer-facing services 
- Structure multi-tenant service monitoring 

**Workflow:** Use this tool to browse hierarchy, then "list\_services" filtered by groupId to see services in specific folder. 

**Important:** A negative "total" value in the response indicates incomplete results. Use pagination (size/offset parameters) or set autoPaginate: true to retrieve all items. 

**Related tools:** "get\_service\_group" (details), "list\_services" (services in group), "create\_service\_group" (create folder). |
| `list_services` | List all business services in LogicMonitor (LM) monitoring. 

**Returns:** Array of services with: id, name, description, health status, dependencies, monitored resources, service level objectives (SLOs), availability percentage. 

**What are services:** Business-level monitoring constructs that aggregate multiple resources/devices/resources into a single health status. Represent customer-facing services, applications, or business processes. Example: "E-Commerce Platform" service includes web servers, databases, load balancers, and APIs - one health indicator for entire platform. 

**When to use:**
- Monitor business service health vs individual resource/device health
- Track SLA compliance for customer-facing services
- Understand service dependencies
- Create business-level dashboards
- Report on application availability


**Service health calculation:** Service health = Aggregate of all dependent resources. If critical resource fails, service status = down. Allows stakeholders to see "Is the application working?" instead of "Is server X working?" 

**Use cases and examples:** 

**Customer-facing services:** 
- "E-Commerce Website" - Web servers + database + payment gateway + CDN 
- "Mobile App Backend" - API servers + auth service + push notifications 
- "SaaS Platform" - All infrastructure for multi-tenant application 

**Internal services:** 
- "Employee VPN" - VPN servers + RADIUS auth + firewall 
- "Corporate Email" - Mail servers + spam filter + archiving 
- "CI/CD Pipeline" - Jenkins + artifact storage + deployment agents 

**Benefits:** 
- **Business perspective:** Non-technical stakeholders understand "Shopping Cart is 99.5% available" 
- **SLA tracking:** Measure uptime for customer SLAs 
- **Root cause:** When service is down, see which specific resource failed 
- **Dependencies:** Visualize what resources comprise a service 

**Common filter patterns:** 
- By status: filter:"status:normal" or filter:"status:dead" 
- By name: filter:"name~*production*" 

**Workflow:** Use this tool to find services, then "get\_service" for detailed dependency tree and health status. 

**Important:** A negative "total" value in the response indicates incomplete results. Use pagination (size/offset parameters) or set autoPaginate: true to retrieve all items. 

**Related tools:** "get\_service" (details and dependencies), "list\_service\_groups" (organization), "create\_service" (define new business service). |
| `list_users` | List all users in LogicMonitor (LM) monitoring. 

**Returns:** Array of users with: id, username, email, roles, status (active/suspended), last login time, created date, API token count. 

**When to use:** 
- Audit user access
- Find user IDs for API token management
- Check who has admin access
- Identify inactive users
- Compliance reporting

**Common filter patterns:** 
- Active users: filter:"status:active"
- By email: filter:"email\~\*@company.com"
- By role: filter:"roles:\*administrator\*"
- Recent logins: filter:"lastLoginOn>{epoch}"
- Never logged in: filter:"lastLoginOn:0"

**Important:** A negative "total" value in the response indicates incomplete results. Use pagination (size/offset parameters) or set autoPaginate: true to retrieve all items. 

**Related tools:** "get\_user" (details), "list\_roles" (available roles), "list\_api\_tokens" (user's API tokens). |
| `list_website_checkpoints` | List available checkpoint locations for website monitoring in LogicMonitor (LM) monitoring. 

**Returns:** Array of checkpoint locations with: id, name, geographic region, status, type (internal/external). 

**What are checkpoints:** Global testing locations from which LogicMonitor runs synthetic website checks. Think "test my website from New York, London, Tokyo" - checkpoints are those global vantage points. 

**When to use:**
- Check available checkpoint locations before creating website monitors
- Verify geographic coverage for multi-region testing
- Select appropriate locations for SLA monitoring
- Plan website monitoring strategy


**Checkpoint types:** 
- **External (Cloud):** LogicMonitor-managed locations around the world (US-East, EU-West, Asia-Pacific, etc.) 
- **Internal (Collector-based):** Tests run from your own collectors (test internal apps, VPNs, private networks) 

**Common checkpoint locations:** 
- North America: US-East, US-West, US-Central, Canada 
- Europe: EU-West (Ireland), EU-Central (Frankfurt), UK 
- Asia-Pacific: Singapore, Sydney, Tokyo 
- South America: São Paulo 

**Use cases:** 
- **Global SLA monitoring:** Test from regions where customers are located 
- **CDN verification:** Ensure content delivery works worldwide 
- **Regional compliance:** Monitor from specific geographic locations 
- **Multi-region performance:** Compare response times across locations 
- **Failover testing:** Verify DR sites accessible from all regions 

**Best practices:** 
- Select checkpoints near your user base 
- Use multiple checkpoints for critical services (avoid false positives from single location issues) 
- Mix internal and external checkpoints for comprehensive coverage 
- Consider timezone differences for result interpretation 

**Workflow:** Use this tool to discover available locations, then use those checkpoint IDs when creating website monitors via "create\_website". 

**Related tools:** "list\_websites" (existing monitors), "create\_website" (configure checkpoints), "get\_website" (verify checkpoint configuration). |
| `list_website_groups` | List all website groups (folders) in LogicMonitor (LM) monitoring. 

**Returns:** Array of website groups with: id, name, parentId, full path, description, number of websites, number of subgroups. 

**What are website groups:** Organizational folders for website monitors (synthetic checks), similar to resource/device groups. Used to categorize monitored URLs/services by application, environment, or customer. 

**When to use:** 
- Browse website organization before creating monitors
- Find group IDs for website operations
- Understand monitoring hierarchy
- Navigate to specific website folders

**Common organization patterns:** 
- By application: "E-Commerce Site", "API Endpoints", "Marketing Pages"
- By environment: "Production URLs", "Staging URLs", "DR Sites"
- By location: "US Sites", "EU Sites", "APAC Sites"
- By customer: "Customer A Sites", "Customer B Sites" (MSP)
- By type: "Public Websites", "Internal Apps", "Third-Party APIs"

**Use cases:** 
- Organize monitors by application or service
- Group customer-facing vs internal endpoints
- Separate production vs non-production monitoring
- Structure multi-region website monitoring

**Workflow:** Use this tool to browse hierarchy, then "list\_websites" filtered by groupId to see monitors in specific folder. 

**Important:** A negative "total" value in the response indicates incomplete results. Use pagination (size/offset parameters) or set autoPaginate: true to retrieve all items. 

**Related tools:** "get\_website\_group" (details), "list\_websites" (websites in group), "create\_website\_group" (create folder). |
| `list_websites` | List all website monitors (synthetic checks) in LogicMonitor (LM) monitoring. 

**Returns:** Array of website monitors with: id, name, type (webcheck/pingcheck), domain/URL, status, checkpoint locations, response time, availability percentage. 

**What are website monitors:** Synthetic checks that test URL/service availability from multiple global locations. Like "ping from the internet" to verify your services are accessible. 

**When to use:** 
- List all monitored URLs/services
- Check website availability status
- Find website IDs for other operations
- Audit monitored endpoints

**Monitor types:** 
- webcheck: Full HTTP/HTTPS check (status code, response time, content validation, SSL cert)
- pingcheck: Simple ICMP ping test (faster, simpler)

**Common filter patterns:** 
- By domain: filter:"domain\~\*example.com\*"
- By type: filter:"type:webcheck" or filter:"type:pingcheck"
- By status: filter:"overallAlertStatus:critical" (find down sites)
- By name: filter:"name\~\*production\*"

**Use cases:** Monitor public websites, API endpoints, login pages, load balancer health checks, SaaS service availability. 

**Important:** A negative "total" value in the response indicates incomplete results. Use pagination (size/offset parameters) or set autoPaginate: true to retrieve all items. 

**Related tools:** "get\_website" (details), "create\_website" (add new), "generate\_website\_link" (get URL). |

## License

GNU General Public License v3.0+
