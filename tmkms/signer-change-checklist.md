# Signer change checklist

Full procedure: [Key Custody and Signer Change](https://services.validexis.com/celestia-infrastructure/key-custody-and-signer-change). Rehearse on Mocha first.

## 1. Fence
- [ ] `systemctl disable --now tmkms` on the current signer
- [ ] Current signer blocked from the validator's `26658/tcp` at the firewall
- [ ] Validator shows no connected signer

## 2. Carry state
- [ ] Key **and** full signing state copied to the new signer's LUKS volume
- [ ] Last signed height / round / step recorded from the old state file: `________`
- [ ] Copy matches the record
- [ ] State not rebuilt from chain height

## 3. Review (second operator)
- [ ] Old signer stopped, disabled, firewalled — confirmed by: `________`
- [ ] New `tmkms.toml`: correct chain ID and validator
- [ ] Only one signer can reach the validator

## 4. Resume
- [ ] New TMKMS started; first signatures in the log
- [ ] `cometbft_privval_signing_latency_median_seconds` < 5 ms
- [ ] `cometbft_privval_signing_failures_total` flat
- [ ] Old signer stays disabled until wiped

**Missing or inconsistent state → signing stays disabled** until the version-specific recovery procedure is completed and independently reviewed.
