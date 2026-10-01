#!/bin/bash
# Sysbench CPU Benchmark Configuration
# Evaluates prime calculation up to 20000 across multiple threads
PRIME_LIMIT=20000
THREADS=(1 2 4 8)
sysbench cpu --cpu-max-prime=$PRIME_LIMIT run
