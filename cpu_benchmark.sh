#!/bin/bash
set -e

echo -e "\e[1;35m🔹 Starting Celestia CPU Benchmark...\e[0m"
sleep 1

# Create a temporary directory for benchmark
cd /tmp
rm -rf celestia-benchmark
git clone https://github.com/celestiaorg/celestia-app.git celestia-benchmark
cd celestia-benchmark
git pull origin main

# Navigate to the benchmark tool directory
cd tools/cpu_requirements

echo -e "\e[1;34m📊 Running benchmark (this may take several minutes)...\e[0m"
nice -n 19 go run main.go | tee $HOME/cpu_benchmark_result_$(date +%Y%m%d_%H%M).txt

# Clean up temporary files
cd /tmp && rm -rf celestia-benchmark

echo -e "\n\e[1;32m✅ Benchmark completed!\e[0m"
echo -e "Results saved to: \e[1;33m~/cpu_benchmark_result_$(date +%Y%m%d_%H%M).txt\e[0m"
