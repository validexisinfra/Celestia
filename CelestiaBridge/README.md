# 🌉 Celestia Bridge Nodes Registry

This repository serves as a public registry for **Celestia Bridge Node operators**, allowing validators to associate their:

- ✅ **Bridge Node Peer ID**
- ✅ **On-chain validator address**
- ✅ **Additional metadata** (logo, socials, Keybase, etc.)

with their **validator identity**.

> 🛰️ Data submitted here is used by [https://celestiabridge.com](https://celestiabridge.com) and other tools in the ecosystem to **verify** and **display** bridge node operators.

---

## 🛠 How to Register Your Bridge Node

Follow these simple steps to get listed:

### 1. Fork this repository  
Click the **Fork** button in the top-right of the page.

### 2. Create your metadata file  
Navigate to the `CelestiaBridge/` directory in your fork.  
Create a new file named `<your_validator_or_keybase_id>.json`  
_(e.g., `validexis.json`)_

### 3. Use the following format:

<details>
<summary>Click to expand JSON format</summary>

```json
{
  "keybaseIdentity": "DD010D13A474ACA3",
  "name": "Validexis",
  "website": "https://validexis.com",
  "email": "info@validexis.com",
  "validatorAddress": "celestiavaloper1abc123...",
  "bridgeNodeID": "12D3KooWQqwe12345abc...",
  "logo": "https://validexis.com/logo.png",
  "telegram": "validexis",
  "twitter": "validexis",
  "github": "validexisinfra",
  "description": "Validator and infra provider for Celestia and other Cosmos-based networks"
}
</details>

> 📌 **Note:** Please use **direct URLs** to PNG or SVG logos.  
> 🧾 **Keep the description under 300 characters.**

---

## 🔍 How to Find Your Bridge Node Peer ID

Run this command on your Celestia bridge node:

```bash
celestia p2p info --node.store ~/.celestia-bridge-mocha-4/

Copy the **Peer ID** from the output and paste it into the `bridgeNodeID` field of your JSON file.

---

## 📤 Submission Process

1. Commit your `.json` file to your fork  
2. Open a **Pull Request (PR)** to this repository  
3. Once reviewed and merged, your metadata will be picked up automatically by [https://celestiabridge.com](https://celestiabridge.com) and similar tools

---

## ✅ Example

See [`bridge_nodes/validexis.json`](./bridge_nodes/validexis.json) for a real-world example.

---

## 📬 Contact

If you have any questions or need help:

- Telegram: [@validexis](https://t.me/validexis)
- GitHub: [https://github.com/validexisinfra](https://github.com/validexisinfra)

