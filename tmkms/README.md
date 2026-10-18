# TMKMS templates for Celestia v10 and Fibre

TMKMS **v0.15.0** added support for Celestia's raw-byte signing extension (`SignRawBytes`), which Fibre needs for payment-promise endorsements and its TLS identity ([changelog](https://github.com/iqlusioninc/tmkms/blob/main/CHANGELOG.md)).

Guides: **[TMKMS for Celestia v10 and Fibre](https://services.validexis.com/validator-security-our-approach-and-protection-measures/tmkms-for-remote-signing/tmkms-for-celestia-v10-and-fibre)** · **[Key Custody and Signer Change](https://services.validexis.com/celestia-infrastructure/key-custody-and-signer-change)**

| File | Purpose |
|---|---|
| [`tmkms.toml.example`](tmkms.toml.example) | softsign provider, key and state on a LUKS volume, validator pinned by node ID |
| [`tmkms.service`](tmkms.service) | systemd unit that waits for the encrypted volume |
| [`signer-change-checklist.md`](signer-change-checklist.md) | Fence → carry state → second-operator review → resume |

## Rules we follow

- One active signer per key; never TMKMS and a local key at the same time.
- `state_file` is double-sign protection — it moves with the key and is never reset.
- Missing or inconsistent state keeps signing disabled until reviewed recovery.
- Median node → KMS latency alert at 5 ms (Celestia requirement: 10 ms).
- Mocha first, Mainnet after.
