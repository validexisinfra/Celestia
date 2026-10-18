# Fibre server templates

Templates for running a Celestia Fibre server on a **dedicated host** next to the validator, as VALIDEXIS does on Mainnet Beta (`v10.4.0`) and Mocha (`v10.4.0-mocha`).

Guide: **[Fibre Server: Setup and Operations](https://services.validexis.com/celestia-infrastructure/fibre-server-setup-and-operations)** · Upstream: [Run a Fibre server](https://docs.celestia.org/operate/consensus-validators/fibre/)

| File | Purpose |
|---|---|
| [`server_config.toml.example`](server_config.toml.example) | Fibre config: application gRPC, privval gRPC with mTLS, client port, connection limits |
| [`validator-config.toml.snippet`](validator-config.toml.snippet) | Validator `app.toml` / `config.toml` settings for a remote Fibre server and TMKMS |
| [`fibre.service`](fibre.service) | systemd unit with OpenTelemetry export |
| [`make-privval-tls.sh`](make-privval-tls.sh) | Issues the CA, validator server certificate and Fibre client certificate |

## Checklist

1. Separate disk for shards; memory sized for `max_connections × max_concurrent_streams × 132 MiB`.
2. Validator: `[grpc] enable = true` on the VLAN address; `priv_validator_grpc_laddr` with all three TLS files.
3. Certificates issued on an admin workstation; `ca.key` kept offline.
4. Firewall: `7980` public; `9090` and `26669` on the validator only from the Fibre host.
5. Start Fibre only after `abci_info` reports app version ≥ 10.
6. Register `<public_host>:7980` with `tx valaddr set-host`; verify with `query valaddr provider`.

> Placeholders only — no real addresses, keys or certificates are stored in this repository.
