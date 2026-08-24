# LogicMonitor webhook payload contract

The EDA rulebook in `rulebooks/logicmonitor_network.yml` matches a **demo
schema**, not LogicMonitor's native alert JSON.

This mapping is designed, not live-verified. Token names and Custom HTTP
Raw JSON substitution come from LogicMonitor docs / product knowledge,
not a captured webhook POST. After the first live alert, confirm the
rendered body still has `type`, `host`, and `id` as in the templates.
Do not rename those keys to native LM field names.

Native Custom HTTP tokens such as `##ALERTTYPE##` expand to values like
`alert` or `eventAlert`. They never equal `bgp_peer_down` or
`bgp_flapping`. Create **one Custom HTTP Delivery integration per
maturity stage** and paste the matching template as Raw JSON so the
hardcoded `type` field routes the event.

| Stage | Integration name (suggested) | Template | Rulebook `type` |
|-------|------------------------------|----------|-----------------|
| Crawl | AAP Crawl BGP Peer Down | `crawl-bgp-peer-down.json` | `bgp_peer_down` |
| Walk | AAP Walk BGP Flapping | `walk-bgp-flapping.json` | `bgp_flapping` |
| Run | AAP Run Unmatched | `run-unmatched.json` | `network_anomaly_unknown` |

Assign each integration to the corresponding LogicMonitor alert rule
(BGP peer down, BGP flapping / instability, and a catch-all or test
rule).

## Field mapping

| Rulebook / extra var | JSON key | LM token | Notes |
|----------------------|----------|----------|-------|
| `event.payload.type` | `type` | *(hardcoded)* | Do not use `##ALERTTYPE##` for routing |
| `event.payload.host` | `host` | `##HOST##` | Must match AAP inventory hostname (`router1`, `router2`, `router3`) |
| `event.payload.id` | `id` | `##INTERNALID##` | Unique per alert session; use this for ack |
| (informational) | `alert_id` | `##ALERTID##` | LM display ID; not unique per session |
| (informational) | `severity` | `##LEVEL##` | |
| (informational) | `message` | `##MESSAGE##` | |
| (informational) | `lm_alert_type` | `##ALERTTYPE##` | Preserved native type |

`validation/test_*.sh` and `playbooks/simulate_unknown_alert.yml` POST
this same schema so standalone tests and live LM alerts hit the same
rules.

## LogicMonitor UI steps

1. Settings → Integrations → Add → **Custom HTTP Delivery**.
2. Method `POST`. URL = the AAP Event Stream URL (not `:5000/logicmonitor`
   when Event Streams are in use).
3. Content-Type `application/json`.
4. Alert Data → **Raw** → **JSON**. Paste one template file.
5. Repeat for the other two stage templates.
6. Point BGP-related alert rules at the Crawl or Walk integration.
   Point a test or unmatched rule at the Run integration.

Name LM devices `router1` / `router2` / `router3` (or set the display
name to those values) so `##HOST##` matches `inventory/hosts.yml`.

## Authentication (HMAC vs Token)

LogicMonitor Custom HTTP Delivery substitutes tokens into the body and
optional static headers. It does **not** compute GitHub-style
`X-Hub-Signature-256` over the body.

- Full bootstrap defaults to a **Token Event Stream**. Put
  `eda_event_stream_token` on the LM integration as a static header
  (`Authorization` unless you override `eda_event_stream_header`).
- Set `eda_event_stream_auth: hmac` only for `validation/test_*.sh`
  posts that set `EDA_HMAC_SECRET`. Custom HTTP cannot HMAC-sign.

## Example rendered Crawl payload

After token substitution a Crawl alert looks like:

```json
{
  "type": "bgp_peer_down",
  "severity": "critical",
  "host": "router2",
  "id": "DS123456789",
  "alert_id": "LMD1234",
  "message": "BGP neighbor 10.1.12.1 state changed to Idle",
  "datasource": "BGP Peers",
  "datapoint": "status",
  "instance": "10.1.12.1",
  "lm_alert_type": "alert"
}
```

EDA then sees `event.payload.type == "bgp_peer_down"` and launches
Reset BGP Session with `affected_host=router2` and `alert_id` set to
the internal id.
