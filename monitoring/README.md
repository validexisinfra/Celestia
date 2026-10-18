# Monitoring — Celestia validators, Fibre and TMKMS

Templates behind our monitoring guide:
**[Monitoring Celestia Validators and Fibre](https://services.validexis.com/monitoring/monitoring-celestia-validators-and-fibre)**

| File | Purpose |
|---|---|
| [`alerts/celestia-validator-fibre.rules.yml`](alerts/celestia-validator-fibre.rules.yml) | Prometheus alert rules: remote-signing latency and failures, missed blocks, chain stall, Fibre errors, disk, network, SSD wear |
| [`otel/otel-collector.yaml.example`](otel/otel-collector.yaml.example) | OpenTelemetry Collector receiving Fibre OTLP and exposing it to Prometheus |

## Thresholds

| Signal | Alert |
|---|---|
| Median node → KMS signing latency (`cometbft_privval_signing_latency_median_seconds`) | > 5 ms (Celestia requirement: ≤ 10 ms) |
| Remote-signing failures (`cometbft_privval_signing_failures_total`) | any increase |
| Missed blocks | > 20 per hour |
| Chain progress | no new block for 60 s |
| Fibre upload / sign errors | error rate above baseline |
| Disk, public port | > 70% |
| SSD wear | > 80% |

Unacknowledged critical alerts escalate by phone after 15 minutes. An off-site monitor in another city checks chain progress and public Fibre reachability.

## Dashboards

Import the official Fibre dashboards from celestia-app:
[`fibre.json`](https://github.com/celestiaorg/celestia-app/blob/v10.4.0-mocha/observability/docker/grafana/dashboards/fibre.json) ·
[`fibre-runtime.json`](https://github.com/celestiaorg/celestia-app/blob/v10.4.0-mocha/observability/docker/grafana/dashboards/fibre-runtime.json)

> Templates contain placeholders only. Validate metric names against your own Prometheus before enabling the rules.
