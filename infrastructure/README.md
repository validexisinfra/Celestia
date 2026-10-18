# VALIDEXIS Celestia infrastructure

How VALIDEXIS runs Celestia **Mainnet Beta** and **Mocha**: validators, Fibre servers and TMKMS signers in one site.

Full write-up: **[Celestia Infrastructure by VALIDEXIS](https://services.validexis.com/celestia-infrastructure)**

## Site and roles

**Rackzar Cape Town DC1, South Africa** — 6 dedicated servers on one private VLAN, one role per server.

| Role | Mainnet | Mocha | Runs | Public exposure |
|---|---|---|---|---|
| Validator | ✓ | ✓ | `celestia-appd` | P2P |
| Fibre | ✓ | ✓ | `fibre` | client port `7980` |
| Signer | ✓ | ✓ | `tmkms` v0.15.0, softsign, LUKS | none |

## Connections

```
Fibre ──privval gRPC, mTLS :26669──► Validator ◄──secret connection :26658── TMKMS
Fibre ──application gRPC, VLAN only :9090──► Validator
Clients ──TLS (endorsed by the validator key)──► Fibre :7980
```

1. **TMKMS dials the validator** and keeps the connection; the signer has no listening services.
2. **Fibre signs through the validator.** Payment-promise endorsements and the Fibre TLS identity are `SignRawBytes` requests to the validator's privval gRPC endpoint, which forwards them to TMKMS.
3. **No Fibre → signer link.** The consensus key exists online only on the signer.
4. **mTLS** protects the remote privval gRPC connection; application gRPC never leaves the private VLAN.

## In this repository

| Folder | Contents |
|---|---|
| [`../fibre`](../fibre) | Fibre server config, validator-side settings, systemd unit, mTLS certificate script |
| [`../tmkms`](../tmkms) | TMKMS v0.15.0 config with SignRawBytes, systemd unit, signer change checklist |
| [`../monitoring`](../monitoring) | Prometheus alert rules, OpenTelemetry Collector template |

## Guides

- [Fibre Server: Setup and Operations](https://services.validexis.com/celestia-infrastructure/fibre-server-setup-and-operations)
- [TMKMS for Celestia v10 and Fibre](https://services.validexis.com/validator-security-our-approach-and-protection-measures/tmkms-for-remote-signing/tmkms-for-celestia-v10-and-fibre)
- [Key Custody and Signer Change](https://services.validexis.com/celestia-infrastructure/key-custody-and-signer-change)
- [Monitoring Celestia Validators and Fibre](https://services.validexis.com/monitoring/monitoring-celestia-validators-and-fibre)
- [VALIDEXIS Celestia Platform and Methodology](https://services.validexis.com/celestia-infrastructure/validexis-celestia-platform-and-methodology)
