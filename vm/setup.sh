#!/bin/bash
# VM Environment Setup Script
# Installs necessary tools and packages for VM baseline benchmarking

echo "Updating system package repositories..."
sudo apt update

echo "Installing core benchmark tools (sysbench, fio, iperf3, apache2-utils, wrk)..."
sudo apt install -y sysbench fio iperf3 apache2-utils wrk

echo "Installing Python dependencies for analysis..."
sudo apt install -y python3-pip python3-pandas python3-matplotlib python3-numpy

echo "VM setup complete."
