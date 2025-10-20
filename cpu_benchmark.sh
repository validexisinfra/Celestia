#!/bin/bash
set -e

echo -e "\e[1;35m🔹 Starting Celestia CPU Benchmark...\e[0m"
sleep 1

# --- INSTALL GO ---
echo -e "\e[1;34m📦 Installing Go ...\e[0m"
curl -Ls https://go.dev/dl/go1.24.6.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
echo "export PATH=\$PATH:/usr/local/go/bin:\$HOME/go/bin" >> $HOME/.bash_profile
source $HOME/.bash_profile

# --- CREATE TEMP DIR ---
cd /tmp
rm -rf celestia-benchmark
echo -e "\e[1;34m📥 Cloning Celestia repo...\e[0m"
git clone https://github.com/celestiaorg/celestia-app.git celestia-benchmark
cd celestia-benchmark

# --- RUN BENCHMARK ---
cd tools/cpu_requirements
echo -e "\e[1;34m📊 Running benchmark (this may take several minutes)...\e[0m"
nice -n 19 go run main.go | tee $HOME/cpu_benchmark_result_$(date +%Y%m%d_%H%M).txt

# --- CLEANUP ---
cd /tmp && rm -rf celestia-benchmark

echo -e "\n\e[1;32m✅ Benchmark completed!\e[0m"
echo -e "Results saved to: \e[1;33m~/cpu_benchmark_result_$(date +%Y%m%d_%H%M).txt\e[0m"
