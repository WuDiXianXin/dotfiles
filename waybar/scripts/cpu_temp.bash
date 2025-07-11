#!/bin/bash

# 获取CPU温度（保留1位小数）
CPU_TEMP=$(sensors coretemp-isa-0000 | awk '/Package id 0/ {
    gsub(/[+°C]/, "", $4);
    printf "%.1f", $4
}')

# 用awk判断阈值，输出状态类名
CLASS=$(echo "$CPU_TEMP" | awk -v critical=90 -v warning=70 '
    $1 >= critical {print "critical"}
    $1 >= warning && $1 < critical {print "warning"}
    $1 < warning {print ""}
')

# 输出JSON格式（text为显示内容，class为状态类）
echo "{\"text\": \"$CPU_TEMP\", \"class\": \"$CLASS\"}"
