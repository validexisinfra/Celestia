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
git checkout v6.4.10-mocha
make install

print "=== Configuring node ==="
celestia-appd config set client chain-id mocha-4
celestia-appd config set client keyring-backend file
celestia-appd config set client node tcp://localhost:26657
celestia-appd init $MONIKER --chain-id mocha-4

print "=== Downloading genesis and addrbook ==="
wget -O $HOME/.celestia-app/config/genesis.json https://testnets1.validexis.com/celestia/genesis.json
wget -O $HOME/.celestia-app/config/addrbook.json https://testnets1.validexis.com/celestia/addrbook.json

print "=== Configuring peers and seeds ==="
SEEDS="30a8f6668043544ee2d9af9369f0f68ff8cf2c43@seed-celestia-testnet.validexis.com:26656"
PEERS="9d357da286e8278c79ec6ebfc01d295a547ddd98@peer-celestia-testnet.validexis.com:26656,5d0bf034d6e6a8b5ee31a2f42f753f1107b3a00e@65.108.75.179:11656,bab648bac7c56777da56463d2ff328d5b73f8123@152.53.36.47:11656,c2870ce12cfb08c4ff66c9ad7c49533d2bd8d412@185.183.33.109:26656,20c6e72c7cd3b3b37f88d703217576b4f72936d4@185.185.51.34:26656,5415b191808b7c16f2f2795960dde67666b0c71d@212.83.43.61:26656,e4ab3ce43a64f9ca81adec3bf864c6977fce2441@46.4.105.119:26630,9e124462d45c4d22e227f6b0103b88c0a0d0fcd8@38.114.123.239:26656,d882c26ecb59f29166f7f586cf20091ec89ee532@65.109.126.24:26630,b37bb130ceab25d91798d170c1c45644b17c742d@207.121.63.164:26656,0c0dd9d82f3fee847c390dcc59a6e2e4fd6d5df0@78.129.165.37:26656,17a1fd70609562ecb7cd10599e0a7d566d8b8699@88.198.70.23:11656,89a9d5090f22a92fba975899503359e8c52c981b@103.88.233.124:26656,e1b058e5cfa2b836ddaa496b10911da62dcf182e@164.152.161.199:36656,05d1d4acbcce7bd5ec949083b843ebb4251c3acf@84.32.32.140:26656,e726816f42831689eab9378d5d577f1d06d25716@164.152.163.148:36656,1feea4b8b29d6bb9c51dc29d0f2029db06b7219c@169.155.169.214:36656,092654181eef7da8eb0a9bc3bb739fb171a68d40@141.98.217.211:26656,9f675ec089c234da9cc0e48077e1ae458fdf8b60@49.12.82.124:36656,c4fa997e8a69bec5787607e25bfa233f941c5b10@88.198.5.77:29656,6fe60cca3ea1e3e3dfaac76648364b7d66f88106@212.8.252.34:26656,5318579c8b99a9c063c145bdb2fcdd58e74b4448@65.108.228.199:10156"
sed -i -e "/^\[p2p\]/,/^\[/{s/^[[:space:]]*seeds *=.*/seeds = \"$SEEDS\"/}" \
       -e "/^\[p2p\]/,/^\[/{s/^[[:space:]]*persistent_peers *=.*/persistent_peers = \"$PEERS\"/}" $HOME/.celestia-app/config/config.toml

print "=== Setting gas prices, and pruning ==="
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.002utia\"|" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.celestia-app/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"50\"/" $HOME/.celestia-app/config/app.toml

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
curl -L https://snapshots1.validexis.com/celestia-testnet/snap_celestia-prun.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.celestia-app/

print "=== Starting Celestia node ==="
sudo systemctl daemon-reload
sudo systemctl enable celestia-appd
sudo systemctl start celestia-appd
sudo journalctl -u celestia-appd -f
