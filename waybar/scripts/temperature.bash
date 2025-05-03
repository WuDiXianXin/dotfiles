#!/bin/bash

# 获取 CPU 温度
CPU_TEMP1=$(cat /sys/class/hwmon/hwmon7/temp1_input)
CPU_TEMP1_C=$(echo "scale=1; $CPU_TEMP1 / 1000" | bc)

# 获取 GPU 温度、使用率、显存使用情况
GPU_TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits)
GPU_UTILIZATION=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)
MEMORY_USED=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits)
MEMORY_TOTAL=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits)

# 计算显存使用率
MEMORY_UTILIZATION=$(echo "scale=2; ($MEMORY_USED / $MEMORY_TOTAL) * 100" | bc)

# 获取 NVMe 温度
NVME_TEMP=$(cat /sys/class/hwmon/hwmon2/temp1_input)
NVME_TEMP_C=$(echo "scale=1; $NVME_TEMP / 1000" | bc)

# 输出温度信息及显存使用率
echo " CPU:${CPU_TEMP1_C}°C NVMe:${NVME_TEMP_C}°C NVIDIA:(${GPU_TEMP}°C,${GPU_UTILIZATION}%,${MEMORY_UTILIZATION}%) "
