#!/bin/bash

gpu_data=$(nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total,temperature.gpu --format=csv,noheader,nounits)

# 1. GPU利用率（阈值：70%警告，90%临界）
utilization=$(echo "$gpu_data" | awk -F', ' '{printf "%.1f", $1}')
util_class=$(echo "$utilization" | awk -v critical=90 -v warning=70 '
    $1 >= critical {print "critical"}
    $1 >= warning && $1 < critical {print "warning"}
    $1 < warning {print ""}
')

# 2. 显存利用率计算+阈值判断（用awk纯浮点运算）
mem_used=$(echo "$gpu_data" | awk -F', ' '{printf "%.1f", $2}')
mem_total=$(echo "$gpu_data" | awk -F', ' '{printf "%.1f", $3}')
mem_utilization=$(echo "$mem_used $mem_total" | awk '
    $2 > 0 {printf "%.1f", ($1 / $2) * 100}
    $2 <= 0 {print "0.0"}
')
mem_class=$(echo "$mem_utilization" | awk -v critical=90 -v warning=70 '
    $1 >= critical {print "critical"}
    $1 >= warning && $1 < critical {print "warning"}
    $1 < warning {print ""}
')

# 3. GPU温度（阈值：70℃警告，80℃临界）
temperature=$(echo "$gpu_data" | awk -F', ' '{printf "%.1f", $4}')
temp_class=$(echo "$temperature" | awk -v critical=80 -v warning=70 '
    $1 >= critical {print "critical"}
    $1 >= warning && $1 < critical {print "warning"}
    $1 < warning {print ""}
')

# 保存JSON格式到临时文件（含状态）
tmp_dir="$HOME/.cache/waybar_gpu"
mkdir -p "$tmp_dir"
echo "{\"text\": \"$utilization\", \"class\": \"$util_class\"}" >"$tmp_dir/utilization.json"
echo "{\"text\": \"$mem_utilization\", \"class\": \"$mem_class\"}" >"$tmp_dir/mem_utilization.json"
echo "{\"text\": \"$temperature\", \"class\": \"$temp_class\"}" >"$tmp_dir/temperature.json"
