#!/bin/bash
rm -rf $HOME/celestia-app
git clone https://github.com/celestiaorg/celestia-app/
cd $HOME/celestia-app
git checkout v8.0.3
make install

sudo systemctl restart celestia-appd && sudo journalctl -fu celestia-appd -o cat
