#!/bin/bash
# VM Baseline Benchmark Execution Script
# Executes CPU, Memory, Disk, and Network tests on the VM directly

RESULTS_DIR="../results/raw"
mkdir -p "$RESULTS_DIR/cpu" "$RESULTS_DIR/memory" "$RESULTS_DIR/disk" "$RESULTS_DIR/network"

echo "=== Running Sysbench CPU on VM ==="
sysbench cpu --cpu-max-prime=20000 --threads=4 run > "$RESULTS_DIR/cpu/vm_cpu.txt"

echo "=== Running Sysbench Memory on VM ==="
sysbench memory --memory-block-size=1M --memory-total-size=10G --threads=4 run > "$RESULTS_DIR/memory/vm_memory.txt"

echo "=== Running Disk Benchmark on VM ==="
mkdir -p /tmp/vm_test
fio --name=vm_seq_write --filename=/tmp/vm_test/testfile --size=1G --bs=1M --rw=write --direct=1 --iodepth=16 --runtime=30 --time_based > "$RESULTS_DIR/disk/vm_disk.txt"
rm -rf /tmp/vm_test

echo "VM baseline benchmarks completed successfully."
