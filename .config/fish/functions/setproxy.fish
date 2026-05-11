function setproxy --description "设置 HTTP/HTTPS/SOCKS5 代理"
    set -l default_ip "192.168.2.5"
    set -l default_http 17890
    set -l default_socks 17891

    set -l ip $argv[1]
    test -z "$ip"; and set ip $default_ip
    set -l http_port $argv[2]
    test -z "$http_port"; and set http_port $default_http
    set -l socks_port $argv[3]
    test -z "$socks_port"; and set socks_port $default_socks

    if string match -rq '^[0-9]{1,3}\.[0-9]{1,3}$' $ip
        set ip "192.168.$ip"
    end

    set -gx http_proxy "http://$ip:$http_port"
    set -gx https_proxy $http_proxy
    set -gx all_proxy "socks5://$ip:$socks_port"
    set -gx no_proxy "localhost,127.0.0.1,::1,192.168.0.0/16"

    echo "✅ 代理已开启 → HTTP: $http_proxy  SOCKS5: $all_proxy"
end
