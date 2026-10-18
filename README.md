# Celestia

Scripts, templates and guides from VALIDEXIS — Celestia Mainnet Beta and Mocha validator and Fibre operator.

## 🏗️ Production setup — validators, Fibre and TMKMS

| Folder | What is inside | Guide |
|---|---|---|
| [`infrastructure/`](infrastructure) | 6 servers in Cape Town, roles and connections | [Celestia Infrastructure](https://services.validexis.com/celestia-infrastructure) |
| [`fibre/`](fibre) | Fibre `server_config.toml`, validator settings, systemd, mTLS certificates | [Fibre Server: Setup and Operations](https://services.validexis.com/celestia-infrastructure/fibre-server-setup-and-operations) |
| [`tmkms/`](tmkms) | TMKMS v0.15.0 with SignRawBytes, softsign + LUKS, signer change checklist | [TMKMS for Celestia v10 and Fibre](https://services.validexis.com/validator-security-our-approach-and-protection-measures/tmkms-for-remote-signing/tmkms-for-celestia-v10-and-fibre) |
| [`monitoring/`](monitoring) | Prometheus alert rules, OpenTelemetry Collector for Fibre | [Monitoring Celestia Validators and Fibre](https://services.validexis.com/monitoring/monitoring-celestia-validators-and-fibre) |

All ecosystem tools, guides and endpoints: **[Tools.md](Tools.md)** · Platform: **[VALIDEXIS Celestia](https://celestia.validexis.com/new2/)**

> Templates contain placeholders only. No addresses, keys or certificates are stored in this repository.

---

## 🧩 Benchmark Node Resources  
**Before installation — check your hardware.**  
Use this script to test your server’s performance and verify whether it meets Celestia validator hardware requirements.  
The benchmark performs several CPU-intensive tasks and saves results to a local file.

### ⚙️ Run Benchmark  
~~~bash
source <(curl -s https://raw.githubusercontent.com/validexisinfra/Celestia/main/cpu_benchmark.sh)
~~~

### 📄 View Results  
~~~bash
cat ~/cpu_benchmark_result_*.txt
~~~

> 💡 **Note:**  
> This script runs entirely in a temporary directory (`/tmp`) and does **not affect your running node or blockchain data**.

---

# Celestia Setup & Upgrade Scripts
A collection of automated scripts for setting up and upgrading Celestia nodes on both Testnet (Mocha-4) and Mainnet.

---

## 🌟 Testnet Setup (Mocha-4)

### ⚙️ Validator Node Setup  
Set up a Validator Node on the Mocha-4 testnet to securely participate in block validation.

~~~bash
source <(curl -s https://raw.githubusercontent.com/validexisinfra/Celestia/main/setup_validator_testnet.sh)
~~~

### ⚙️ Consensus Full Node Setup  
Deploy a Consensus Full Node that stores the entire blockchain and verifies transactions.

~~~bash
source <(curl -s https://raw.githubusercontent.com/validexisinfra/Celestia/main/setup_archiv_testnet.sh)
~~~

### ⚙️ Bridge Node Setup  
Set up a Bridge Node to connect the Celestia testnet with external networks.

~~~bash
source <(curl -s https://raw.githubusercontent.com/validexisinfra/Celestia/main/setup_bridge_testnet.sh)
~~~

---

## 🌟 Mainnet Setup

### ⚙️ Validator Node Setup  
Deploy a Validator Node on Celestia Mainnet and contribute to network security.

~~~bash
source <(curl -s https://raw.githubusercontent.com/validexisinfra/Celestia/main/setup_validator_mainnet.sh)
~~~

### ⚙️ Consensus Full Node Setup  
Run a Consensus Full Node to store all blockchain data and ensure transaction validation.

~~~bash
source <(curl -s https://raw.githubusercontent.com/validexisinfra/Celestia/main/setup_archiv_mainnet.sh)
~~~

### ⚙️ Bridge Node Setup  
Configure a Bridge Node to facilitate data availability and cross-network interoperability.

~~~bash
source <(curl -s https://raw.githubusercontent.com/validexisinfra/Celestia/main/setup_bridge_mainnet.sh)
~~~

---

## 🔄 Upgrade Scripts

### 🔄 Upgrade Testnet App  
Update your Celestia app on the testnet to the latest version.

~~~bash
source <(curl -s https://raw.githubusercontent.com/validexisinfra/Celestia/main/upgrade_testnet_app.sh)
~~~

### 🔄 Upgrade Testnet Bridge  
Ensure your testnet node runs the latest protocol updates.

~~~bash
source <(curl -s https://raw.githubusercontent.com/validexisinfra/Celestia/main/upgrade_testnet_node.sh)
~~~

### 🔄 Upgrade Mainnet App  
Keep your Celestia app on the mainnet up-to-date.

~~~bash
source <(curl -s https://raw.githubusercontent.com/validexisinfra/Celestia/main/upgrade_mainnet_app.sh)
~~~

### 🔄 Upgrade Mainnet Bridge  
Upgrade your mainnet node for full protocol compatibility.

~~~bash
source <(curl -s https://raw.githubusercontent.com/validexisinfra/Celestia/main/upgrade_mainnet_node.sh)
~~~

---

### 📌 How to Use  
Copy the relevant command for your setup.  

Paste it into your Linux terminal and execute.  

Follow on-screen instructions.  

💡 Tip: Always ensure your system meets the required dependencies before running scripts.
