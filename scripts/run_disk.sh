#!/bin/bash
OUTPUT_DIR="../results/raw/disk"
mkdir -p "$OUTPUT_DIR" ~/fio-test

echo "Running Sequential Write Disk Benchmark..."
fio --name=seq-write \
    --filename=~/fio-test/testfile \
    --size=2G \
    --bs=1M \
    --rw=write \
    --direct=1 \
    --iodepth=16 \
    --runtime=30 \
    --time_based > "$OUTPUT_DIR/seq-write.txt"

echo "Disk benchmark completed."
