# Go_Volt Operational Observability & Monitoring Guide

This guide defines the observability, structured logging, metric collection, and alerting architecture for Go-Volts in accordance with **Technical Specification §13 (Reporting and Operational Observability)**.

---

## 1. Structured JSON Logging

All Go-Volts services (API backend, background workers, integration webhooks) MUST emit structured JSON logs to `stdout`/`stderr`. Log aggregators (e.g., Datadog, Grafana Loki, CloudWatch) parse these streams directly.

### 1.1 JSON Schema

```json
{
  "timestamp": "2026-10-26T14:32:00.123Z",
  "level": "INFO",
  "service": "govolts-api",
  "environment": "production",
  "trace_id": "c1f7b093-4a18-4c8d-b08e-5b1b4834ff2d",
  "request_id": "req-988471-a20",
  "actor_id": "usr_99214_cust",
  "actor_role": "customer",
  "method": "POST",
  "route": "/api/v1/bookings/estimate",
  "status": 200,
  "latency_ms": 42.15,
  "message": "Ride estimate generated successfully",
  "metadata": {
    "zone_id": "zone_lekki",
    "vehicle_tier": "electric_moped",
    "distance_km": 8.4,
    "quote_id": "quo_892144"
  }
}
```

### 1.2 Mandatory Fields

| Field | Type | Description |
|---|---|---|
| `timestamp` | ISO-8601 UTC String | Precise timestamp of the event. |
| `level` | String (`DEBUG`, `INFO`, `WARN`, `ERROR`, `FATAL`) | Severity level. |
| `service` | String | Subsystem name (`govolts-api`, `govolts-worker`, `govolts-pos`). |
| `environment` | String | `production`, `staging`, or `development`. |
| `trace_id` | String (UUIDv4) | Distributed trace correlation identifier. |
| `request_id` | String | Inbound HTTP request header `X-Request-ID`. |
| `actor_id` | String (Optional) | Authenticated user or partner ID. |
| `route` | String | Normalized URL route pattern (e.g., `/api/v1/bookings/:id`). |
| `status` | Integer | HTTP response status code. |
| `latency_ms` | Float | Request processing duration in milliseconds. |

---

## 2. Redaction & Privacy Policy (Spec §13.2)

To comply with NDPR and international privacy standards, the following fields **MUST NEVER** appear in logs or unencrypted analytics:

| Category | Forbidden In Plaintext | Permitted Masked Pattern |
|---|---|---|
| **Auth Tokens** | JWT, Refresh tokens, Partner API Keys, Webhook Secrets | `REDACTED` or hash prefix (e.g., `gv_sec_****1234`) |
| **Payment Credentials** | Card PAN, CVV, Card PIN, Bank account numbers | Only last 4 digits (e.g., `**** 1121`) |
| **Customer Phone Numbers** | `+2348012345678` | Masked middle: `+234 801 *** 5678` |
| **Precise Geolocation** | Exact home/office addresses, door numbers | Truncated to zone or LGA (e.g., `Lekki Phase 1, Lagos`) |
| **Passwords / PINs** | Customer PIN, Rider unlock PIN | Completely excluded |

---

## 3. Metrics Catalog & Prometheus Endpoints

The Go-Volts backend exposes metrics on `/metrics` formatted for Prometheus scraping.

### 3.1 Financial & Transactional Metrics
- `govolts_ledger_imbalance_cents` (Gauge): Difference between ledger debits and credits. Must equal 0.
- `govolts_wallet_credit_liability_kobo` (Gauge): Total unredeemed customer wallet balances.
- `govolts_payment_initializations_total` (Counter, labels: `provider`, `currency`): Payment attempts.
- `govolts_payment_success_total` (Counter, labels: `provider`, `currency`): Confirmed payment receipts.
- `govolts_payment_verification_failures_total` (Counter, labels: `provider`, `reason`): Gateway mismatches or timeouts.
- `govolts_refunds_processed_total` (Counter, labels: `reason`, `authorized_by`): Approved refunds.

### 3.2 Dispatch & Operations Metrics
- `govolts_bookings_requested_total` (Counter, labels: `zone`, `tier`): Booking creation requests.
- `govolts_bookings_completed_total` (Counter, labels: `zone`, `tier`): Completed deliveries/rides.
- `govolts_bookings_cancelled_total` (Counter, labels: `reason`, `cancelled_by`): Cancelled bookings.
- `govolts_dispatch_assignment_duration_seconds` (Histogram): Time from booking request to rider acceptance.
- `govolts_bookings_stuck_unassigned_count` (Gauge): Current bookings awaiting rider beyond timeout.
- `govolts_active_riders_online_gauge` (Gauge, labels: `zone`, `status`): Online/busy riders.
- `govolts_battery_swaps_completed_total` (Counter, labels: `station_id`): Battery swap cycles.

### 3.3 System & Infrastructure Metrics
- `govolts_http_requests_total` (Counter, labels: `method`, `route`, `status`): Traffic throughput.
- `govolts_http_request_duration_seconds` (Histogram, labels: `route`): Latency buckets.
- `govolts_db_active_connections` (Gauge): Pool connections in use.
- `govolts_outbox_events_backlog_count` (Gauge): Unsent transactional events.

---

## 4. Alerting Thresholds & On-Call Playbook

| Alert Name | Severity | Condition | Immediate Action |
|---|---|---|---|
| **`LedgerImbalanceDetected`** | Critical | Imbalance != 0 for > 1 min | 1. Page Finance Lead & Lead Backend Engineer.<br>2. Temporarily pause automated wallet withdrawals.<br>3. Inspect latest ledger journal entries via admin console. |
| **`RepeatedPaymentVerificationFailures`** | Critical | Failure rate > 5% for > 3 mins | 1. Check Paystack status page.<br>2. Verify webhook secret signature rotation in backend environment.<br>3. Check payment gateway IP whitelisting. |
| **`HighApiErrorRate`** | Critical | 5xx errors > 2% for > 2 mins | 1. Check backend container health logs.<br>2. Verify database connection pool saturation.<br>3. Inspect recent deployment diff. |
| **`DatabaseConnectionPoolSaturated`** | Critical | Active conn > 85% for > 3 mins | 1. Scale backend instances or increase PgBouncer pool limits.<br>2. Check for long-running unindexed queries. |
| **`StuckBookingsDetected`** | Warning | Unassigned bookings > 5 for > 5 mins | 1. Check rider supply in impacted zone.<br>2. Inspect dispatch worker logs for dispatch queue deadlocks. |
| **`GrowingQueueAgeOutboxBacklog`** | Warning | Outbox backlog > 100 for > 3 mins | 1. Check outbox worker process status.<br>2. Restart outbox relay if worker thread died. |

---

## 5. Running Prometheus & Grafana Locally

From the repository root:

```bash
# Start backend stack with monitoring exporters
docker compose -f infra/docker/docker-compose.yml up -d

# Verify metrics endpoint is active
curl http://localhost:8080/metrics

# Verify health endpoint
curl http://localhost:8080/health
```
