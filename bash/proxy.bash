#!/bin/bash

# ========== 代理管理 ==========
# 使用示例：
#   setproxy              # 使用默认 192.168.2.5:17890/17891
#   setproxy 3.100        # 自动补全为 192.168.3.100
#   setproxy 10.0.0.1 8080 1080   # 完整 IP + 自定义端口
#   unsetproxy            # 关闭代理
#   proxy                 # 查看当前所有代理变量
PROXY_IP_DEFAULT="192.168.2.5"
PROXY_PORT_HTTP=17890
PROXY_PORT_SOCKS=17891

setproxy() {
  local ip="${1:-$PROXY_IP_DEFAULT}"
  local http="${2:-$PROXY_PORT_HTTP}"
  local socks="${3:-$PROXY_PORT_SOCKS}"

  # 如果只输入了“数字.数字”，自动补全 192.168.
  if [[ "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    ip="192.168.$ip"
  fi

  export http_proxy="http://$ip:$http"
  export https_proxy="$http_proxy"
  export all_proxy="socks5://$ip:$socks"
  export no_proxy="localhost,127.0.0.1,::1,192.168.0.0/16"

  echo "✅ 代理已开启 → HTTP: $http_proxy  SOCKS5: $all_proxy"
}

unsetproxy() {
  unset http_proxy https_proxy all_proxy no_proxy
  echo "🛑 代理已关闭"
}

proxy() {
  for v in http_proxy https_proxy all_proxy no_proxy; do
    printf "%s=%s\n" "$v" "${!v:-未设置}"
  done
}
