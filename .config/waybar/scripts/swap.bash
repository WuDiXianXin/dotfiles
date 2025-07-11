#!/bin/bash

# 获取Swap使用率
swap_info=$(free | awk '/^交换/ {
    used = $3; total = $2;
    if (total > 0) {
        util = (used / total) * 100;
        printf "%.1f", util;
    } else {
        print "无Swap";
    }
}')

# 判断状态（仅当有Swap时生效）
if [[ "$swap_info" != "无Swap" ]]; then
  class=$(echo "$swap_info" | awk -v critical=80 -v warning=60 '
        $1 >= critical {print "critical"}
        $1 >= warning && $1 < critical {print "warning"}
        $1 < warning {print ""}
    ')
else
  class=""
fi

# 输出JSON
echo "{\"text\": \"$swap_info\", \"class\": \"$class\"}"
