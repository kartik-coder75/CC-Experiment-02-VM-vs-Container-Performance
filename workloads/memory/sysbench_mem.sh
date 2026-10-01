#!/bin/bash
# Sysbench Memory Benchmark Configuration
# Sequential write test with 1M block size and 10G total transfer
sysbench memory \
    --memory-block-size=1M \
    --memory-total-size=10G \
    --memory-oper=write \
    --threads=4 run
