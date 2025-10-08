#!/bin/bash

set -e

# Colors for better readability
GREEN="\e[32m"
NC="\e[0m"

print() {
    echo -e "${GREEN}$1${NC}"
}

# Prompt for RPC_NODE_IP
read -p "Enter your RPC_NODE_IP: " RPC_NODE_IP

print "Updating system and installing dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install curl git wget htop tmux build-essential jq make lz4 gcc unzip -y

print "Installing Go 1.24.2..."
sudo rm -rf /usr/local/go
curl -Ls https://go.dev/dl/go1.24.2.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/golang.sh
echo 'export PATH=$PATH:$HOME/go/bin' >> $HOME/.profile
echo "export PATH=\$PATH:/usr/local/go/bin:\$HOME/go/bin" >> $HOME/.bash_profile
source $HOME/.bash_profile
go version

print "Building Celestia Node (v0.27.3)..."
cd $HOME
rm -rf celestia-node
git clone https://github.com/celestiaorg/celestia-node
cd celestia-node/
git checkout tags/v0.27.4-mocha
make build 
sudo make install 
make cel-key

print "Initializing Celestia Bridge Node..."
celestia bridge init --core.ip $RPC_NODE_IP --p2p.network mocha

print "Listing your Bridge Node wallet address..."
$HOME/celestia-node/cel-key list --node.type bridge --keyring-backend test --p2p.network mocha

print "Creating systemd service for Celestia Bridge..."

sudo tee /etc/systemd/system/celestia-bridge.service > /dev/null <<EOF
[Unit]
Description=celestia Bridge
After=network-online.target
​
[Service]
User=$USER
ExecStart=$(which celestia) bridge start \
--p2p.network mocha --archival \
--metrics.tls=true --metrics --metrics.endpoint otel.mocha.celestia.observer
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
​
[Install]
WantedBy=multi-user.target
EOF

print "Enabling and starting Celestia Bridge Node..."
sudo systemctl daemon-reload
sudo systemctl enable celestia-bridge
sudo systemctl restart celestia-bridge

print "You can now monitor the Bridge Node logs using:"
echo "  sudo journalctl -u celestia-bridge -f"

print "✅ Setup complete!"
