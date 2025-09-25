#!/bin/bash
sudo systemctl stop celestia-bridge
cd $HOME
rm -rf celestia-node
git clone https://github.com/celestiaorg/celestia-node.git
cd celestia-node/
git checkout tags/v0.27.3-mocha 
make build 
sudo make install 
make cel-key
celestia bridge config-update --p2p.network mocha
systemctl restart celestia-bridge && journalctl -u celestia-bridge -f -o cat
