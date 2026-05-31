function unsetproxy --description 关闭代理
    set -e http_proxy
    set -e https_proxy
    set -e all_proxy
    set -e no_proxy
    echo "🛑 代理已关闭"
end
