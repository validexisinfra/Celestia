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
curl -Ls https://go.dev/dl/go1.23.6.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
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
git checkout v3.8.1
make install

print "=== Configuring node ==="
celestia-appd config chain-id celestia
celestia-appd config keyring-backend file
celestia-appd config node tcp://localhost:26657
celestia-appd init "$MONIKER" --chain-id celestia

print "=== Downloading genesis and addrbook ==="
wget -O $HOME/.celestia-app/config/genesis.json https://server-3.itrocket.net/mainnet/celestia/genesis.json
wget -O $HOME/.celestia-app/config/addrbook.json  https://server-3.itrocket.net/mainnet/celestia/addrbook.json

print "=== Configuring peers and seeds ==="
SEEDS="12ad7c73c7e1f2460941326937a039139aa78884@celestia-mainnet-seed.itrocket.net:40656"
PEERS="d535cbf8d0efd9100649aa3f53cb5cbab33ef2d6@celestia-mainnet-peer.itrocket.net:26656,1a13ea9e5d0de48ca47bb670b4eb25507f91054f@34.22.145.167:26656,6467b17fdd14fbbe1eb90df94f287f8c4169a41c@136.243.95.125:26656,ff2088fe31a66724589a9bddf84d80981ddcacb3@176.9.10.245:26656,383ca09b031aceceeb5a5ef37e4f1b5a5bd16134@46.4.80.48:11656,5c2cd4773fc6582a56038bf2932f816f3eb564be@37.27.123.68:26656,639125b86fca2473e5a92b0d1e6c137024bbec7e@46.166.162.73:26656,d99aec7727865baeb2f408ac80b120b1e14cffd1@65.109.122.249:11656,8240e8a13594d40b6839f183795c551503309d3c@51.15.16.101:26656,1fcfc74c1d32a49a59d545f23d3da838eb94dcc3@185.135.81.50:31006,4364d34a856abb631c9872502f9ea304e1fbbcb8@65.108.231.237:11656,28cde43d29c8534c52cbdf40deb05c04e694b144@8.219.148.195:26656,06babc4601365cc46b93d5d065c1089d8c19cebc@65.109.89.19:11656,b5e35a266fd455ef81bec7cc1606c377e80f3058@74.118.139.94:26656,ae70fd00ab841ca2f70b9b2dcc6d65dbe9a534a3@65.108.232.104:11656,57307aa4cac3b00aace33d34fe0a7c52e290705f@154.60.100.64:27657,674e4c80644a944e3b1f21061308d2a5979785e2@37.27.134.181:1500,735f27e760bf281f47ead41c42bd4bc2309fcf53@65.21.136.219:11026,63e4bb93ae34fdf3b0efb48071a102f1bcbb83e9@54.220.166.232:26656,87af580078c80c630625db2360b3dc19483d29cd@217.28.48.233:26656,acca7837e4eb5f9dc7f5a94ed1d82edda6931ff8@135.181.246.172:26656,9f15a15c4442c52fff5125c5e1e0dd4e6d9bb970@95.216.71.19:11656,b35ff7f853eb424f5e8d2eb53540564913490f4b@195.201.106.166:11656,3f5b7d5d6d770082ea067c8404658c93d862babe@88.218.224.14:26656,fc1a1df1ba1b62fd6494f99fd956e4e31cdcdd0c@152.53.228.126:40656,761973c2e641b6770c727ab800b3fb2124b29328@144.76.15.125:34656,a7ca111a7a4951caaeb595c41b049bc8300202b1@67.209.54.198:26656,a02a5bcc78a33526300f7550f552fcd1fd133db7@141.98.217.135:26656,d00942da93f790767d515b0ae2fd700272b0147c@141.98.217.124:26656,deee84ece18f31efec8f9bc699b2377a4c0c0714@74.118.143.164:26656"

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
curl -L https://celestia-snapshots.kjnodes.com/celestia-archive/snapshot_latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.celestia-app

print "=== Starting Celestia node ==="
sudo systemctl daemon-reload
sudo systemctl enable celestia-appd
sudo systemctl start celestia-appd
sudo journalctl -u celestia-appd -f
