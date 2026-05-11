function proxy --description 查看当前代理环境变量
    for var in http_proxy https_proxy all_proxy no_proxy
        if set -q $var
            printf '%s=%s\n' $var (eval echo \$$var)
        else
            printf '%s=%s\n' $var 未设置
        end
    end
end
