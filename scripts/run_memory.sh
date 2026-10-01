#!/bin/bash
OUTPUT_DIR="../results/raw/memory"
mkdir -p "$OUTPUT_DIR"

echo "Running Memory Benchmark..."
sysbench memory \
    --memory-block-size=1M \
    --memory-total-size=10G \
    --threads=4 \
    run > "$OUTPUT_DIR/memory_run.txt"

echo "Memory benchmark completed."
