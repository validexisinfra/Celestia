#!/bin/bash
set -e

echo -e "\e[1;35m🔹 Starting Celestia CPU Benchmark...\e[0m"
sleep 1

# --- INSTALL GO ---
echo -e "\e[1;34m📦 Installing Go ...\e[0m"
curl -Ls https://go.dev/dl/go1.24.6.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
eval $(echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/golang.sh)
eval $(echo 'export PATH=$PATH:$HOME/go/bin' | tee -a $HOME/.profile)
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile
source $HOME/.bash_profile

# --- DOWNLOAD BENCHMARK TOOL ONLY ---
echo -e "\e[1;34m⬇️ Downloading Celestia CPU benchmark tool...\e[0m"
sudo apt install -y subversion
cd /tmp
rm -rf cpu_requirements
svn export https://github.com/celestiaorg/celestia-app/trunk/tools/cpu_requirements cpu_requirements
cd cpu_requirements

echo -e "\e[1;34m📊 Running benchmark (this may take several minutes)...\e[0m"
nice -n 19 go run main.go | tee $HOME/cpu_benchmark_result_$(date +%Y%m%d_%H%M).txt

# Clean up temporary files
cd /tmp && rm -rf celestia-benchmark

echo -e "\n\e[1;32m✅ Benchmark completed!\e[0m"
echo -e "Results saved to: \e[1;33m~/cpu_benchmark_result_$(date +%Y%m%d_%H%M).txt\e[0m"
