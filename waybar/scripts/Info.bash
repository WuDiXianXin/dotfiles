#!/bin/bash

# 获取 CPU 温度（Package id 0）
CPU_TEMP=$(sensors coretemp-isa-0000 | awk '/Package id 0/ {gsub(/[+]/, "", $4); print $4}')

# 获取 NVMe 温度
NVME_TEMP=$(sensors nvme-pci-0200 | awk '/Composite/ {gsub(/[+]/, "", $2); print $2}')

# 获取 GPU 温度、使用率、显存使用情况
GPU_TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits)
GPU_UTILIZATION=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)
MEMORY_USED=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits)
MEMORY_TOTAL=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits)

# 计算显存使用率
MEMORY_UTILIZATION=$(echo "scale=2; ($MEMORY_USED / $MEMORY_TOTAL) * 100" | bc)

# 输出温度信息及显存使用率
echo " CPU:${CPU_TEMP} NVMe:${NVME_TEMP} NVIDIA:(${GPU_TEMP}°C,${GPU_UTILIZATION}%,${MEMORY_UTILIZATION}%) "
