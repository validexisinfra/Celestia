# 🚀 Celestia Tools Hub  
A collection of essential tools, scripts, guides, and security solutions for Celestia.  

---

<h2 align="center">🌟 Quick Navigation</h2>

<p align="center">
📌 <a href="#security--monitoring">Security</a> |
<a href="#guides--tutorials">Guides</a> |
<a href="#automation--scripts">Scripts</a> |
<a href="#networks--endpoints">Endpoints</a> |
<a href="#snapshots">Snapshots</a> |
<a href="#bots--notifications">Bots</a>
</p>

---
<a name="security"></a>
## 🔐 Security & Monitoring  
> _"Security first! Protect your Celestia node and monitor its health."_

### 🛡️ Validator Security
- 🔒 [Enhancing SSH Security for a Validator](https://services.validexis.com/validator-security-our-approach-and-protection-measures/enhancing-ssh-security-for-a-validator)  
- 🧑‍💻 [TMKMS for Remote Signing](https://services.validexis.com/validator-security-our-approach-and-protection-measures/tmkms-for-remote-signing)  
- 🔑 [Horcrux](https://services.validexis.com/validator-security-our-approach-and-protection-measures/horcrux)  
- 🛡️ [Protecting Validator from DDoS Attacks](https://services.validexis.com/validator-security-our-approach-and-protection-measures/protecting-validator-from-ddos-attacks)  
- 🧬 [Multi-Factor Authentication (MFA) for a Validator](https://services.validexis.com/validator-security-our-approach-and-protection-measures/multi-factor-authentication-mfa-for-a-validator)

### 🚨 Monitoring
- 📊 [Node-exporter + Prometheus + Grafana](https://services.validexis.com/monitoring/node-exporter-+-prometheus-+-grafana)  
- 🧭 [TenderDuty for Node Monitoring](https://services.validexis.com/monitoring/tenderduty-for-node-monitoring)



---

## 📖 Guides & Tutorials  
> _"Master Celestia step by step with these comprehensive guides."_


---
<a name="scripts"></a>
## ⚙️ Automation & Scripts  
> _"Save time with powerful scripts for automation."_ 

### 🛠 Celestia Setup Scripts  
⚙️ **Validator Node Setup** → [Testnet](https://github.com/validexisinfra/Celestia?tab=readme-ov-file#%EF%B8%8F-validator-node-setup-1) | [Mainnet](https://github.com/validexisinfra/Celestia?tab=readme-ov-file#%EF%B8%8F-validator-node-setup-1)   
⚙️ **Consensus Full Node Setup** → [Testnet](https://github.com/validexisinfra/Celestia?tab=readme-ov-file#%EF%B8%8F-consensus-full-node-setup) | [Mainnet](https://github.com/validexisinfra/Celestia?tab=readme-ov-file#%EF%B8%8F-consensus-full-node-setup-1)  
⚙️ **Bridge Node Setup** → [Testnet](https://github.com/validexisinfra/Celestia?tab=readme-ov-file#%EF%B8%8F-consensus-full-node-setup-1) | [Mainnet](https://github.com/validexisinfra/Celestia?tab=readme-ov-file#%EF%B8%8F-bridge-node-setup-1)  

### 🔄 Celestia Upgrade Scripts  
🔄 **Upgrade Celestia App** → [Testnet](https://github.com/validexisinfra/Celestia?tab=readme-ov-file#-upgrade-testnet-app) | [Mainnet](https://github.com/validexisinfra/Celestia?tab=readme-ov-file#-upgrade-mainnet-app)  
🔄 **Upgrade Node** → [Testnet](https://github.com/validexisinfra/Celestia?tab=readme-ov-file#-upgrade-mainnet-app) | [Mainnet](https://github.com/validexisinfra/Celestia?tab=readme-ov-file#-upgrade-mainnet-bridge)  

---

## 🌐 Networks & Endpoints  
> _"Reliable endpoints, peers, and bootstrap files for Celestia Mainnet & Testnet by Validexis."_

### 🔵 Mainnet

#### 🌐 Endpoints
- 📡 **API**: [`https://api-celestia-mainnet.validexis.com/`](https://api-celestia-mainnet.validexis.com/)  
- 🔗 **RPC**: [`https://rpc-celestia-mainnet.validexis.com/`](https://rpc-celestia-mainnet.validexis.com/)  
- 🔌 **gRPC**: `grpc-celestia-mainnet.validexis.com:443`

#### 🛠️ Ports
- 📍 **RPC**: `26657`  
- 📍 **gRPC**: `9090`

#### 🤝 Persistent Peer
- 🔗 `60d481edb7e49efe01fa0b49a346cf9f8400db19@peer-celestia-mainnet.validexis.com:26656`

#### 🧩 AddrBook (updated hourly)
```bash
wget -O $HOME/.celestia-app/config/addrbook.json https://mainnets.validexis.com/celestia/addrbook.json
```

#### 📜 Genesis File
```bash
wget -O $HOME/.celestia-app/config/genesis.json https://mainnets.validexis.com/celestia/genesis.json
```

### 🧪 Testnet

#### 🌐 Endpoints
- 📡 **API**: [`https://api-celestia-testnet.validexis.com/`](https://api-celestia-testnet.validexis.com/)  
- 🔗 **RPC**: [`https://rpc-celestia-testnet.validexis.com/`](https://rpc-celestia-testnet.validexis.com/)  
- 🔌 **gRPC**: `grpc-celestia-testnet.validexis.com:443`

#### 🛠️ Ports
- 📍 **RPC**: `26657`  
- 📍 **gRPC**: `9090`

#### 🤝 Persistent Peer
- 🔗 `fac5acd6540dd788dc804c8bd307b5169e666e68@peer-celestia-testnet.validexis.com:26656`

#### 🧩 AddrBook (updated hourly)
```bash
wget -O $HOME/.celestia-app/config/addrbook.json https://testnets.validexis.com/celestia/addrbook.json
```

#### 📜 Genesis File
```bash
wget -O $HOME/.celestia-app/config/genesis.json https://testnets.validexis.com/celestia/genesis.json
```
---

## 🗂️ Snapshots

> _Ready-to-use Celestia snapshots (Pruned, Archive, and Bridge) by Validexis._

#### 🔵 Mainnet Snapshots

📦 Available types at  
[`https://services.validexis.com/mainnets/celestia/snapshot`](https://services.validexis.com/mainnets/celestia/snapshot):

- ♻️ **Pruned Node Snapshot** — faster sync, minimal storage  
- 🗃️ **Archive Node Snapshot** — full history, for indexers  
- 🌉 **Bridge Node Snapshot** — for Celestia Bridge nodes

#### 🧪 Testnet Snapshots

📦 Available types at  
[`https://services.validexis.com/testnets/celestia/snapshot`](https://services.validexis.com/testnets/celestia/snapshot):

- ♻️ **Pruned Node Snapshot** — faster sync, minimal storage  
- 🗃️ **Archive Node Snapshot** — full history, for indexers  
- 🌉 **Bridge Node Snapshot** — for Celestia Bridge nodes

---  

## 🤖 Bots & Notifications  
> _"Stay informed with smart bots & alerts."_
