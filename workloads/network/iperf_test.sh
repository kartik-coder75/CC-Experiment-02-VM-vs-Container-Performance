#!/bin/bash
# iperf3 Network Benchmark Configuration
# Measures bandwidth across 4 parallel TCP connections over 30 seconds
TARGET_IP=${1:-"127.0.0.1"}
iperf3 -c "$TARGET_IP" -t 30 -P 4
