# Performance Analysis of Virtual Machines and Containers

> Experimental comparison of the performance, resource utilization, application performance, and scalability of Virtual Machines (VMware Workstation + Ubuntu) and Docker Containers under identical workloads.

---

## Abstract

This project experimentally compares a Virtual Machine environment (Ubuntu guest on VMware Workstation) with a Docker container environment by running identical workloads in both. The workloads cover CPU (Sysbench), memory (Sysbench), disk I/O (fio), network (iperf3), a FastAPI web application (Apache Benchmark / wrk), startup time, and scalability under increasing load. Every experiment is repeated multiple times, raw outputs are stored unaltered, and results are processed with Python (Pandas, Matplotlib) to obtain mean, median, min, max, and standard deviation. The conclusions are based only on the measured data.

<!-- TODO: After finishing the experiments, add 2-3 sentences summarizing the key findings (e.g., which environment performed better in which workload, and by what percentage). -->

---

## Objectives

- Prepare and document a controlled experimental environment for VM and container testing.
- Establish a baseline using a common CPU workload.
- Measure and compare CPU, memory, disk I/O, and network performance.
- Compare application-level performance using a FastAPI service.
- Measure application and environment startup time.
- Study scalability as workload (threads / concurrent connections) increases.
- Automate benchmarks and process results using CSV files and Python.
- Publish scripts, raw data, graphs, and documentation on GitHub so the experiment is reproducible.

---

## Research Questions

1. How does CPU performance (events/sec, execution time) differ between a VM and a container?
2. How does memory throughput and latency differ between the two environments?
3. How do sequential and random disk read/write performance (MB/s, IOPS, latency) differ?
4. How do network throughput and retransmissions differ?
5. How does a realistic application (FastAPI) perform in terms of requests/sec, latency, and failed requests?
6. Which environment starts faster (environment startup and application-ready time)?
7. How does each environment scale as the number of threads or concurrent connections increases?

---

## Experimental Environment

```
┌───────────────────────────────────────────────┐
│            EXPERIMENTAL ENVIRONMENT           │
├───────────────────────────────────────────────┤
│ Host OS         →  Windows                    │
│ Hypervisor      →  VMware Workstation         │
│ Guest OS        →  Ubuntu                     │
│ Container       →  Docker                     │
│ Programming     →  Python                     │
│ CPU Benchmark   →  Sysbench                   │
│ Disk Benchmark  →  fio                        │
│ Network         →  iperf3                     │
│ API             →  FastAPI                    │
│ Analysis        →  Pandas / Matplotlib        │
└───────────────────────────────────────────────┘
```

---

## Hardware Configuration

### Host machine

| Item | Value |
|------|-------|
| CPU model | 12th Gen Intel(R) Core(TM) i5-12500H |
| Physical cores / threads | 4 |
| RAM | 4GB |
| Storage type (SSD/HDD/NVMe) | SSD |
| Host OS | Windows 11 |

### VM configuration (fixed allocation)

| Item | Value |
|------|-------|
| vCPU | 4 |
| Memory | 8 GB |
| Virtual disk | 100GB |
| Guest OS | Ubuntu 24.04.5.1-desktop amd64 |
| Network adapter | NAT |

### Container configuration (controlled limits)

| Item | Value |
|------|-------|
| CPU limit | --cpus=4 |
| Memory limit | --memory=8g |
| Base image | ubuntu:24.04.5.1 |
| Storage | host directory |
| Network mode | bridge |

Raw system information is stored in `docs/cpu-info.txt`, `docs/memory-info.txt`, `docs/storage-info.txt`, `docs/kernel-info.txt`, and `docs/vm-configuration.txt`.

---

## Software Configuration

| Software | Purpose | Version |
|----------|---------|---------|
| Ubuntu | Guest OS / container base | Ubuntu 24.04.5.1-desktop amd64 |
| VMware Workstation | Hypervisor | 17.6.4 |
| Docker | Container runtime | docker 29.1.3 |
| Sysbench | CPU and memory benchmark | sysbench 1.0.20 |
| fio | Disk I/O benchmark | fio-3.36 |
| iperf3 | Network benchmark | iperf3 3.16 |
| Python | Analysis and API | python 3.12.3  |
| FastAPI / Uvicorn | Application workload | FastAPI 0.141.1 / Uvicorn 0.54.0 |
| Apache Benchmark (ab) / wrk | HTTP load testing | ApacheBench, Version 2.3  |
| Pandas / Matplotlib / NumPy | Result analysis | pandas 2.1.4 / matplotlib 3.6.3 / numpy 1.26.4 |

---

## Architecture

```
              PERFORMANCE ANALYSIS
                      │
        ┌─────────────┴─────────────┐
        │                           │
     VIRTUAL                    CONTAINER
     MACHINE                      Docker
        │                           │
        └─────────────┬─────────────┘
                      │
                SAME WORKLOADS
                      │
        ┌─────────────┼─────────────┐
        ▼             ▼             ▼
       CPU         Memory     Disk / Network
                      │
                      ▼
               APPLICATION TEST
                      │
                      ▼
                FINAL ANALYSIS
```

![Architecture diagram](docs/architecture.png)

---

## Methodology

- The **same workload and parameters** are executed in both the VM and the container.
- VM resources are fixed; the container is limited with `--cpus` and `--memory` to match.
- Each experiment is repeated **10 times** to reduce the effect of temporary fluctuations.
- Complete raw outputs are saved in `results/raw/`; they are never edited.
- Cleaned values go into `results/processed/*.csv` and are analyzed with Python.
- Percentage differences are computed with a consistent formula:

  - Execution time: `((vm_time - container_time) / vm_time) × 100`
  - Throughput: `((container_throughput - vm_throughput) / vm_throughput) × 100`

- No assumption is made beforehand that either environment performs better.

Full details: [`docs/methodology.md`](docs/methodology.md)

---

## CPU Experiment

| Parameter | Value |
|-----------|-------|
| Tool | Sysbench |
| Workload | Prime number calculation |
| `--cpu-max-prime` | 20000 |
| Threads | 1 / 2 / 4 / 8 |
| Duration | 30 seconds |
| Repetitions | 10 |
| Metrics | Events/sec, execution time |

```bash
sysbench cpu --cpu-max-prime=20000 --threads=4 --time=30 run
```

Container:

```bash
docker run --rm --cpus=4 --memory=8g vm-container-benchmark \
  sysbench cpu --cpu-max-prime=20000 --threads=4 --time=30 run
```

Raw data: `results/raw/cpu/` · Processed data: `results/processed/cpu_results.csv`

---

## Memory Experiment

| Parameter | Value |
|-----------|-------|
| Tool | Sysbench |
| Block size | 1M |
| Total size | 10G |
| Threads | 4 |
| Repetitions | 10 |
| Metrics | Operations/sec, throughput (MiB/s), latency |

```bash
sysbench memory --memory-block-size=1M --memory-total-size=10G --threads=4 run
```

Resource usage during the run is monitored using `htop`, `vmstat 1`, and `docker stats`.

Raw data: `results/raw/memory/`

---

## Disk I/O Experiment

| Parameter | Value |
|-----------|-------|
| Tool | fio |
| Test file size | 2G |
| Direct I/O | `--direct=1` |
| IO depth | 16 |
| Runtime | 30 s (time-based) |
| Tests | Sequential read/write (1M blocks), random read/write (4k blocks) |
| Metrics | MB/s, IOPS, latency |

```bash
fio --name=seq-write --filename=~/fio-test/testfile --size=2G --bs=1M \
    --rw=write --direct=1 --iodepth=16 --runtime=30 --time_based
```

Container (host directory mounted with `-v`):

```bash
docker run --rm -v ~/fio-test:/fio-test vm-container-benchmark \
  fio --name=seq-write --filename=/fio-test/testfile --size=2G --bs=1M \
      --rw=write --direct=1 --iodepth=16 --runtime=30 --time_based
```

Raw data: `results/raw/disk/`

> Storage placement (host directory vs. Docker volume) is documented because it can change measured results.

---

## Network Experiment

| Parameter | Value |
|-----------|-------|
| Tool | iperf3 |
| Duration | 30 s |
| Streams | 1 and 4 (`-P 4`) |
| Metrics | Throughput, retransmissions |
| Network mode | NAT |

```bash
# Server
iperf3 -s

# Client
iperf3 -c <SERVER-IP> -t 30
iperf3 -c <SERVER-IP> -t 30 -P 4
```

Raw data: `results/raw/network/`

---

## Application Experiment

A FastAPI application (`api/main.py`) with three endpoints is run identically in the VM and in Docker:

| Endpoint | Purpose |
|----------|---------|
| `/health` | Lightweight health check |
| `/compute` | CPU-intensive loop (1,000,000 iterations) |
| `/memory` | Memory allocation (list of 1,000,000 integers) |

Load testing:

```bash
ab -n 10000 -c 100 http://127.0.0.1:8000/health
ab -n 1000  -c 10  http://127.0.0.1:8000/compute
wrk -t4 -c100 -d30s http://127.0.0.1:8000/health
```

Metrics recorded: requests per second, time per request, failed requests, connection times.

Docker image: `performance-api` (built from `api/Dockerfile`).

---

## Startup-Time Experiment

Measures how quickly the environment and the application become ready.

```bash
time docker run --rm -d --name startup-test -p 8000:8000 performance-api
docker stop startup-test
```

| Item | VM | Container |
|------|----|-----------|
| Environment startup | 21.47s | 1.67s |
| Application ready | 22.3s | 2.1s |

Multiple repetitions are performed because startup time varies.

---

## Scalability Experiment

| Test | Levels |
|------|--------|
| CPU (Sysbench threads) | 1 → 2 → 4 → 8 |
| API (wrk) | `-t1 -c10` → `-t2 -c50` → `-t4 -c100` → `-t4 -c200` |

Throughput, latency, CPU usage, and memory usage are recorded at each workload level.

---

## Results

> Populate only with actual measured values. Include units (seconds, MB/s, IOPS, Mbps, requests/sec, ms).

### CPU

| Threads | VM (events/s) | Container (events/s) |
|---------|---------------|----------------------|
| 1 | 7450 | 7520 |
| 2 | 14920 | 15040 |
| 4 | 3204.70 | 3372.40 |
| 8 | 3244.24 | 2856.71 |

![CPU performance](results/figures/cpu_performance.png)
![CPU scalability](results/figures/cpu_scalability.png)

### Memory, Disk, Network, Application, Startup, Scalability

Add the corresponding tables and graphs from `results/processed/` and `results/figures/`.

---

## Statistical Analysis

For each metric, the following statistics are calculated over the repeated runs using Pandas:

| Statistic | Meaning |
|-----------|---------|
| Mean | Average performance across runs |
| Median | Reduces the influence of outliers |
| Min / Max | Range of observed values |
| Standard deviation | Run-to-run variation |

```python
summary = df.groupby("environment")["events_per_second"].agg(
    ["mean", "median", "min", "max", "std"]
)
```

Analysis scripts: `scripts/analyze_results.py`, `scripts/generate_plots.py` · Notebook: `analysis/analysis.ipynb`

| Environment | Mean | Median | Min | Max | Std |
|-------------|------|--------|-----|-----|-----|
| VM | 11280.0 | 11280.0 | 7520 | 15040 | 5317.442995 |
| Container | 11185.0 | 11185.0 | 7450 | 14920 | 5282.087655 |

---

## VM vs Container Comparison

| Metric | VM | Container | Difference |
|--------|----|-----------|------------|
| CPU Performance | 15.1 s | 14.9 s | +0.8% (Container faster) |
| Memory Usage | 28332.62 MiB/sec | 9414.91 MiB/sec | -66.8% (VM faster) |
| Sequential Read |1360 MB/s | 1294 MB/s | -4.9% (VM faster) |
| Sequential Write | 495MB/s | 615MB/s | +24.2% (Container faster) |
| Random Read | 24.5MB/s | 24.8MB/s | +1.2% (Container faster) |
| Random Write | 23.3MB/s | 20.0MB/s | -14.2% (VM faster) |
| Network Throughput | 187Gbps | 139 Gbps | -25.7% (VM faster) |
| Startup Time | 21.47 s | 1.67 s | Container is ~92.2% faster |
| API Requests/sec | 2246.67 | 3062.27 | +36.3% (Container faster) |
| API Latency | 44.510 | 32.656 | +26.6% (Container faster / lower latency) |

---

## Discussion

<!-- Write after analysis. Suggested points: -->

- Which environment performed better in each workload, and why (shared host kernel vs. hypervisor layer, virtualized disk and network, resource limits).
- Whether differences are larger than the run-to-run standard deviation (i.e., meaningful).
- Disk and network results in light of the storage placement and network mode used.
- Startup-time behavior and its implications for microservices and rapid deployment.
- Scalability trends as threads and connections increase.

---

## Limitations

- Results depend on the specific host hardware and configuration.
- The VM runs on a Windows host with VMware Workstation, while Docker runs inside the Ubuntu environment, so nested layers may affect results.
- Storage placement and network mode (NAT/Bridged/bridge/host) can change outcomes.
- Synthetic benchmarks and a simple FastAPI app may not represent all production workloads.
- Background host activity can introduce noise despite repeated runs.
- `<add any other limitation observed during your experiments>`

---

## Conclusion

<!-- Base the conclusion strictly on measured data, repeated runs, and statistical analysis. Do not assume beforehand that VMs or containers perform better. -->

Based on the empirical benchmark results collected across CPU, memory, disk I/O, networking, and application performance, we observe the core architectural trade-offs between hypervisor-level virtualization (VMware) and OS-level containerization (Docker):

* **Startup Latency & Agility:** Containers demonstrated a decisive advantage, spinning up in **1.67 s** compared to the VM's cold boot time of **21.47 s** (~92.2% reduction). This directly reflects the container's ability to reuse the host kernel instead of initializing an independent hardware abstraction layer, kernel, and userspace service stack.
* **CPU & Raw Compute:** CPU performance was nearly parity-bound (15.1 s on VM vs. 14.9 s on Container, with a marginal +0.8% container lead), confirming that hardware-assisted CPU virtualization incurs negligible operational overhead for compute-bound tasks.
* **Application Throughput & Latency:** In practical HTTP API workloads, the container served **3,062.27 req/s** at **32.66 ms** mean latency compared to the VM's **2,246.67 req/s** at **44.51 ms** latency (+36.3% higher throughput, +26.6% lower latency), benefiting from lower context-switching overhead and lean execution paths.
* **I/O & Network Paths:** Sequential write throughput favored the container (+24.2%), while the VM maintained higher raw loopback networking throughput (187 Gbps vs. 139 Gbps) due to container network bridge packet filtering and NAT overhead.

### Key Takeaway
Containers provide significant benefits in deployment speed, resource footprint, and application-layer throughput, making them ideal for microservices and cloud-native workloads. Virtual machines remain the industry standard where complete kernel isolation, mixed guest operating systems, and strict security isolation boundaries are prioritized over startup agility.

---

## Future Work

- Extend the experiments to Kubernetes (replicas and autoscaling).
- Test additional workloads (databases, multi-container apps).
- Compare other hypervisors and container runtimes.
- Evaluate different storage drivers and network modes.
- Add long-duration and mixed-workload tests.

---

## Reproduction Instructions

### 1. Clone the repository

```bash
git clone <GITHUB-REPOSITORY-URL>
cd vm-vs-container-performance
```

### 2. Install tools (Ubuntu VM)

```bash
sudo apt update
sudo apt install -y sysbench fio iperf3 htop iotop sysstat python3 python3-pip git apache2-utils
pip install fastapi uvicorn pandas matplotlib numpy jupyter
```

### 3. Install Docker

```bash
sudo apt install -y docker.io
sudo systemctl enable --now docker
sudo usermod -aG docker $USER   # log out and back in
docker run --rm hello-world
```

### 4. Record the environment

```bash
mkdir -p docs results/raw results/processed results/figures scripts workloads
lscpu > docs/cpu-info.txt
free -h > docs/memory-info.txt
lsblk > docs/storage-info.txt
uname -a > docs/kernel-info.txt
```

### 5. Build the Docker images

```bash
docker build -t vm-container-benchmark -f docker/Dockerfile .
docker build -t performance-api -f api/Dockerfile api
```

### 6. Run the benchmarks (from the project root)

```bash
./scripts/run_cpu.sh
./scripts/run_memory.sh
./scripts/run_disk.sh
./scripts/run_network.sh
```

### 7. Analyze the results

```bash
python3 scripts/analyze_results.py
python3 scripts/generate_plots.py
```

### Project structure

```
vm-vs-container-performance/
├── README.md
├── .gitignore
├── docs/          # system info, methodology, architecture
├── vm/            # VM setup and benchmark scripts
├── docker/        # benchmark Dockerfile
├── api/           # FastAPI app, requirements.txt, Dockerfile
├── workloads/     # cpu / memory / disk / network
├── scripts/       # automation and analysis scripts
├── results/       # raw / processed / figures
└── analysis/      # analysis.ipynb
```
