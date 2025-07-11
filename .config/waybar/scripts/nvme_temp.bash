#!/bin/bash

# 获取NVMe温度（保留1位小数）
NVME_TEMP=$(sensors nvme-pci-0200 | awk '/Composite/ {
    gsub(/[+°C]/, "", $2);
    printf "%.1f", $2
}')

# 用awk判断阈值（示例：60℃警告，70℃临界）
CLASS=$(echo "$NVME_TEMP" | awk -v critical=70 -v warning=60 '
    $1 >= critical {print "critical"}
    $1 >= warning && $1 < critical {print "warning"}
    $1 < warning {print ""}
')

# 输出JSON
echo "{\"text\": \"$NVME_TEMP\", \"class\": \"$CLASS\"}"
