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
git checkout v4.0.10
make install

print "=== Configuring node ==="
celestia-appd config chain-id celestia
celestia-appd config keyring-backend file
celestia-appd config node tcp://localhost:26657
celestia-appd init "$MONIKER" --chain-id celestia

print "=== Downloading genesis and addrbook ==="
wget -O $HOME/.celestia-app/config/genesis.json https://mainnets1.validexis.com/celestia/genesis.json
wget -O $HOME/.celestia-app/config/addrbook.json https://mainnets1.validexis.com/celestia/addrbook.json

print "=== Configuring peers and seeds ==="
SEEDS="0074b06d366fe8e1d6a2a53b6752bd55e33267f6@seed-celestia-mainnet.validexis.com:37656"
PEERS="a48c5bb03ff416f6cb0245e0aa42523cc6c9f430@peer-celestia-mainnet.validexis.com:26656,a8ddad6896dddccc42534f24afc6d14bbf278f33@65.109.18.169:11656,b5622df798ab39de650fa2e7c79190a0d3e814e0@137.184.44.109:26656,e263dbf2fbd4734a364dac1236bb8cbd83a0c012@157.90.33.62:28656,d0c4affc656bad26d7a46e4b946c0be71baa4a1f@46.4.51.104:11656,a5f01c0afea36df559b8d92e55626c0b5275dfd0@103.219.169.97:43656,74fc653041a6ca07e3432f6f12e8753e1e4dfe21@38.121.43.84:26656,6ee545c2992a8201ce2ed68d73776695627595db@168.119.37.164:12056,ce99d7da2530f75d05880d13d9eda384d5a1afe4@65.109.34.34:23356,2ae2d3d0b97c4fcd134decb202ac241cd2f44735@37.252.186.118:2000,e6d602f66559ee2a7280a46efbc5f87efe567bcb@139.84.143.106:10456,2fdf0e8288e18f39815a750857414325a07e5fca@218.153.200.72:11002,44336a5aaae84446a31bc6fe22246d8a11af3c90@65.109.19.111:40656,9d4afca92c2d6e681d3605ae25cb1817620a9604@35.195.100.59:26656,c33e89275c461a3871253025a1f5dcde9f8856a2@136.243.67.47:11656,a71a4c58dce5b2268e3c7f229608772327110ee5@65.109.54.91:11056,9cd7540cd22f9a9442af23b5d83c2a69ea4b24c2@62.210.122.96:26656"
sed -i -e "/^\[p2p\]/,/^\[/{s/^[[:space:]]*seeds *=.*/seeds = \"$SEEDS\"/}" \
       -e "/^\[p2p\]/,/^\[/{s/^[[:space:]]*persistent_peers *=.*/persistent_peers = \"$PEERS\"/}" \
       $HOME/.celestia-app/config/config.toml

print "=== Setting commit timeout, gas prices,indexer and pruning ==="
sed -i -e "s|^target_height_duration *=.*|timeout_commit = \"11s\"|" $HOME/.celestia-app/config/config.toml
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.002utia\"|" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^indexer *=.*/indexer = \"kv\"/" $HOME/.celestia-app/config/config.toml

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
curl -L https://snapshots1.validexis.com/celestia-mainnet/snap_celestia-archive_6631124.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.celestia-app/

print "=== Starting Celestia node ==="
sudo systemctl daemon-reload
sudo systemctl enable celestia-appd
sudo systemctl start celestia-appd
sudo journalctl -u celestia-appd -f
