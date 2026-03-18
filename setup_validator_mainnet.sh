#!/bin/bash
set -e

# Colors
GREEN="\e[32m"
RED="\e[31m"
NC="\e[0m"

print() {
    echo -e "${GREEN}$1${NC}"
}

print_error() {
    echo -e "${RED}$1${NC}"
}

# Prompt the user to set MONIKER if it's not already set
read -p "Please enter your MONIKER value: " MONIKER

# If MONIKER is still empty, exit with an error
if [ -z "$MONIKER" ]; then
    print_error "Error: You must set the MONIKER variable to proceed."
    exit 1
fi

print "MONIKER has been set to: $MONIKER"

print "=== Updating system and installing dependencies ==="
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl git wget htop tmux build-essential jq make lz4 gcc unzip

print "=== Installing Go ==="
sudo rm -rf /usr/local/go
curl -Ls https://go.dev/dl/go1.24.6.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/golang.sh > /dev/null
echo 'export PATH=$PATH:$HOME/go/bin' >> $HOME/.profile
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile
source $HOME/.bash_profile
go version

print "=== Cloning and building celestia-app ==="
cd $HOME
rm -rf celestia-app
git clone https://github.com/celestiaorg/celestia-app.git
cd celestia-app
git checkout v6.4.10
make install

print "=== Configuring node ==="
celestia-appd config set client chain-id celestia
celestia-appd config set client keyring-backend file
celestia-appd config set client node tcp://localhost:26657
celestia-appd init "$MONIKER" --chain-id celestia

print "=== Downloading genesis and addrbook ==="
wget -O $HOME/.celestia-app/config/genesis.json https://server-1.itrocket.net/mainnet/celestia/genesis.json
wget -O $HOME/.celestia-app/config/addrbook.json  https://server-1.itrocket.net/mainnet/celestia/addrbook.json

print "=== Configuring peers and seeds ==="
SEEDS="12ad7c73c7e1f2460941326937a039139aa78884@celestia-mainnet-seed.itrocket.net:40656"
PEERS="d535cbf8d0efd9100649aa3f53cb5cbab33ef2d6@celestia-mainnet-peer.itrocket.net:26656,79a1a8857a5342212655432a04777845cc912e28@161.118.209.33:26656,6d661e1af1f53e7cd34664313df055dc40399795@197.85.190.15:26656,5deeddca390a7dd3b54b46e02794ae74b03cd0bd@207.229.99.33:40656,e4a9e9c06cd539a86e7ae172b6c1f6888dd86cb3@23.227.223.129:26656,c150d7d10e74b1be92acdc24bfd7c567a80188d2@64.130.47.114:26656,65a6d964e0598e282b5b413a4884adda22a4f54a@5.199.140.75:2120,c04516cd6cb0e8980dd95a8ea4d6d4aabfd4d984@65.109.19.189:11656,12ad7c73c7e1f2460941326937a039139aa78884@65.109.36.88:40656,4928c12dc8ba4c97bf529296c9321341c6dbcfb1@[2001:bc8:1203:1b2::8]:26656,f7e16376cf0ff73010ddc7299de562d86977c2cc@104.250.153.230:26656"
sed -i -e "/^\[p2p\]/,/^\[/{s/^[[:space:]]*seeds *=.*/seeds = \"$SEEDS\"/}" \
       -e "/^\[p2p\]/,/^\[/{s/^[[:space:]]*persistent_peers *=.*/persistent_peers = \"$PEERS\"/}" $HOME/.celestia-app/config/config.toml

print "=== Setting commit timeout, gas prices, and pruning ==="
sed -i -e "s|^target_height_duration *=.*|timeout_commit = \"11s\"|" $HOME/.celestia-app/config/config.toml
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.002utia\"|" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"19\"/" $HOME/.celestia-app/config/app.toml

print "=== Enabling BBR congestion control ==="
sudo modprobe tcp_bbr
echo "net.core.default_qdisc=fq" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

print "=== Creating systemd service ==="
sudo tee /etc/systemd/system/celestia-appd.service > /dev/null <<EOF
[Unit]
Description=Celestia Node
After=network-online.target

[Service]
User=$USER
WorkingDirectory=$HOME/.celestia-app
ExecStart=$(which celestia-appd) start --home $HOME/.celestia-app
Restart=on-failure
RestartSec=5
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

print "=== Downloading chain snapshot ==="
curl -L https://snapshots.kjnodes.com/celestia/snapshot_latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.celestia-app

print "=== Starting Celestia node ==="
sudo systemctl daemon-reload
sudo systemctl enable celestia-appd
sudo systemctl start celestia-appd
sudo journalctl -u celestia-appd -f
