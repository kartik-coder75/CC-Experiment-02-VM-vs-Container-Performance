# Experimental Methodology

## 1. Objective
To benchmark, measure, and analyze performance overhead and resource scalability between Virtual Machines (VMs) and Docker Containers under identical hardware constraints.

## 2. Tested Environments
- **Virtual Machine:** Ubuntu 24.04 LTS running on VMware Workstation.
- **Container Runtime:** Docker Engine running Ubuntu / Python base images directly sharing the host kernel.

## 3. Workload Benchmarks
- **CPU:** `sysbench --test=cpu --cpu-max-prime=20000` scaling across 1, 2, 4, and 8 threads.
- **Memory:** `sysbench memory` testing multi-threaded sequential read/write operations.
- **Disk I/O:** `fio` measuring sequential and random write/read IOPS and latency.
- **Network:** `iperf3` measuring throughput across multi-parallel connections.
- **Application Load:** FastAPI application benchmarked under concurrency using Apache Benchmark (`ab`) and `wrk`.

## 4. Evaluation Metrics
- Execution time (seconds)
- Throughput (events per second, requests per second)
- Resource utilization (CPU percentage, memory footprint)
- Environment startup latency
