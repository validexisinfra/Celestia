#!/bin/bash
rm -rf $HOME/celestia-app
git clone https://github.com/celestiaorg/celestia-app/
cd $HOME/celestia-app
git checkout v4.0.10
make install

sed -i \
  -e 's|^grpc_laddr *=.*|grpc_laddr = "tcp://127.0.0.1:9098"|' \
  -e 's|^proxy_app *=.*|proxy_app = "tcp://127.0.0.1:36658"|' \
  $HOME/.celestia-app/config/config.toml
​
sudo systemctl restart celestia-appd && sudo journalctl -fu celestia-appd -o cat
