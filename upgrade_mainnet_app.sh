#!/bin/bash
rm -rf $HOME/celestia-app
git clone https://github.com/celestiaorg/celestia-app/
cd $HOME/celestia-app
git checkout v3.8.1
make install
sudo systemctl restart celestia-appd && sudo journalctl -fu celestia-appd -o cat
