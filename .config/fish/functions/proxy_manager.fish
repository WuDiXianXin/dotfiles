function proxy_manager
    # 统一菜单输出格式，增加换行提升可读性
    printf "󰓯 代理作用域管理菜单：\n"
    printf "  1. 设置局域网代理\n"
    printf "  2. 撤销代理\n"
    printf "  3. 查看当前代理配置\n"
    printf "请选择操作 [1-3]:\n"

    read -l choice
    switch $choice
        case 1
            # 1. 交互式输入 IP 最后两段（默认 2.185），增加示例提示
            printf "\n请输入代理 IP 最后两段（格式如 2.185，留空使用默认值 2.185）：\n"
            read -l ip_segments
            # 处理空输入，使用默认值
            if test -z "$ip_segments"
                set ip_segments "2.185"
            end

            # 校验 IP 最后两段的合法性（仅允许 数字.数字 格式）
            if not string match -r '^[0-9]+\.[0-9]+$' "$ip_segments"
                printf "\n❌ 输入格式错误！请按 数字.数字 格式输入（如 2.185）\n"
                return 1 # 退出当前操作，避免无效配置
            end

            # 拼接完整 IP 并校验网段合法性（0-255 范围）
            set proxy_ip "192.168.$ip_segments"
            # 拆分网段验证
            set -l seg1 (string split '.' $ip_segments | head -n1)
            set -l seg2 (string split '.' $ip_segments | tail -n1)
            if test $seg1 -lt 0 -o $seg1 -gt 255 -o $seg2 -lt 0 -o $seg2 -gt 255
                printf "\n❌ IP 网段无效！每段数字需在 0-255 之间\n"
                return 1
            end

            # 2. 交互式输入 HTTP/HTTPS 端口，增加示例和校验
            printf "请输入 HTTP/HTTPS 代理端口（留空使用默认值 17890）：\n"
            read -l http_port
            if test -z "$http_port"
                set http_port 17890
            else if not string match -r '^[0-9]+$' "$http_port" -o $http_port -lt 1 -o $http_port -gt 65535
                printf "\n❌ 端口无效！请输入 1-65535 之间的数字\n"
                return 1
            end

            # 3. 交互式输入 SOCKS5 端口，增加示例和校验
            printf "请输入 SOCKS5 代理端口（留空使用默认值 17891）：\n"
            read -l socks_port
            if test -z "$socks_port"
                set socks_port 17891
            else if not string match -r '^[0-9]+$' "$socks_port" -o $socks_port -lt 1 -o $socks_port -gt 65535
                printf "\n❌ 端口无效！请输入 1-65535 之间的数字\n"
                return 1
            end

            # 4. 设置代理环境变量（全局生效）
            set -gx http_proxy "http://$proxy_ip:$http_port"
            set -gx https_proxy "$http_proxy"
            set -gx all_proxy "socks5://$proxy_ip:$socks_port"
            set -gx no_proxy "localhost,127.0.0.1,::1,192.168.0.0/16" # 补充局域网免代理

        case 2
            # 统一提示风格，增加换行
            if set -q http_proxy
                set -e http_proxy https_proxy all_proxy no_proxy
                printf "\n🛑 全局代理已清除\n"
            else
                printf "\n⚠️  无活跃代理配置\n"
            end

        case 3
            # 初始化标记，判断是否有代理配置
            set -l has_config false

            # 打印美观的表格式配置
            printf "\n📋 当前代理配置：\n"
            printf "+--------+----------------+----------------------------------------+\n"
            printf "| %-6s | %-14s | %-38s |\n" 作用域 变量名 值
            printf "+--------+----------------+----------------------------------------+\n"

            # 遍历代理变量，格式化输出
            for var in http_proxy https_proxy all_proxy no_proxy
                if set -q $var
                    set -l scope (test -g "$$var" && echo "全局" || echo "局部")
                    set -l var_value (eval echo \$$var)
                    if test -z "$var_value"
                        set var_value "（空值）"
                    end
                    printf "| %-6s | %-14s | %-38s |\n" "$scope" "$var" "$var_value"
                    set has_config true
                end
            end

            # 闭合表格边框
            printf "+--------+----------------+----------------------------------------+\n"

            # 无配置时给出提示
            if not $has_config
                printf "\n⚠️  暂无任何代理配置\n"
            end

        case '*'
            # 优化无效输入提示，格式更清晰
            printf "\n󰅖 输入无效！请选择 1-3 之间的数字：\n"
            printf "  1 - 设置局域网代理\n"
            printf "  2 - 撤销代理\n"
            printf "  3 - 查看当前代理配置\n"
    end
end
