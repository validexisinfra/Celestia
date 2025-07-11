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
curl -Ls https://go.dev/dl/go1.24.2.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
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
git checkout v4.0.7-mocha
make install

print "=== Configuring node ==="

celestia-appd config set client chain-id mocha-4
celestia-appd config set client keyring-backend file
celestia-appd config set client node tcp://localhost:26657
​celestia-appd init $MONIKER --chain-id mocha-4

print "=== Downloading genesis and addrbook ==="
wget -O $HOME/.celestia-app/config/genesis.json https://testnets1.validexis.com/celestia/genesis.json
wget -O $HOME/.celestia-app/config/addrbook.json https://testnets1.validexis.com/celestia/addrbook.json

print "=== Configuring peers and seeds ==="

SEEDS="30a8f6668043544ee2d9af9369f0f68ff8cf2c43@seed-celestia-testnet.validexis.com:26656"
PEERS="9d357da286e8278c79ec6ebfc01d295a547ddd98@peer-celestia-testnet.validexis.com:26656,5d0bf034d6e6a8b5ee31a2f42f753f1107b3a00e@65.108.75.179:11656,89cca749b0eab33db47da6015bc5f3845c361964@167.172.30.82:26656,ef713a1700508c9c6a46cc2b61b41a6fa59ac53d@136.243.94.113:26656,227f9c3bf41779ab70187b781cf4de3f387870f0@51.89.21.142:26656,2e28ae4affb16877f4dba754fd4ba5509f669c5f@94.130.221.170:26656,0d25acebc3c65a6e90d0f9b448d4f2f47e5de55e@217.28.56.148:26656"
sed -i -e "/^\[p2p\]/,/^\[/{s/^[[:space:]]*seeds *=.*/seeds = \"$SEEDS\"/}" \
       -e "/^\[p2p\]/,/^\[/{s/^[[:space:]]*persistent_peers *=.*/persistent_peers = \"$PEERS\"/}" $HOME/.celestia-app/config/config.toml

print "=== Setting commit timeout, gas prices, indexer and pruning ==="
sed -i -e "s|^target_height_duration *=.*|timeout_commit = \"11s\"|" $HOME/.celestia-app/config/config.toml
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.002utia\"|" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^indexer *=.*/indexer = \"kv\"/" $HOME/.celestia-app/config/config.toml
​
sed -i \
  -e 's|^pruning *=.*|pruning = "nothing"|' \
  $HOME/.celestia-app/config/app.toml

print "=== Configuring p2p rates ==="
sed -i -e "s|^recv_rate *=.*|recv_rate = 10485760|" \
       -e "s|^send_rate *=.*|send_rate = 10485760|" \
       -e "s|^ttl-num-blocks *=.*|ttl-num-blocks = 12|" \
       $HOME/.celestia-app/config/config.toml

print "=== Set mempool to v1 ==="
sed -i '
/^\[mempool\]/,/^\[/ {
    s/version = .*/version = "v1"/
    s/max_txs_bytes = .*/max_txs_bytes = 39485440/
    s/max_tx_bytes = .*/max_tx_bytes = 7897088/
}' $HOME/.celestia-app/config/config.toml       

print "=== Enabling BBR congestion control ==="
sudo modprobe tcp_bbr
echo "net.core.default_qdisc=fq" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

print "=== Creating systemd service ==="
sudo tee /etc/systemd/system/celestia-appd.service > /dev/null <<EOF
[Unit]
Description=Celestia node
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
curl -L https://snapshots1.validexis.com/celestia-testnet/snap_celestia-archive_7060225.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.celestia-app/

print "=== Starting Celestia node ==="
sudo systemctl daemon-reload
sudo systemctl enable celestia-appd
sudo systemctl start celestia-appd
sudo journalctl -u celestia-appd -f
