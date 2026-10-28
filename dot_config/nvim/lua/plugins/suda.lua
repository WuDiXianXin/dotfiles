return {
    {
        'WuDiXianXin/suda.nvim',

        -- 本地插件目录，按你实际存放位置修改
        -- Local plugin directory; adjust to your actual path
        -- dir = '/git/xx/suda.nvim/',
        -- name = 'suda.nvim',

        -- 启动时加载，确保 :SudaRead / :SudaWrite 一开始就可用
        -- Load at startup so :SudaRead / :SudaWrite are available immediately
        lazy = false,

        -- config = function()
        -- require('suda').setup({
        -- =====================================================================
        -- 提权命令
        -- Privilege escalation command
        -- =====================================================================

        -- 默认值：'sudo'
        -- Default: 'sudo'
        -- executable = 'sudo',

        -- 使用 doas：
        -- Using doas:
        -- executable = 'doas',

        -- 使用绝对路径：
        -- Using an absolute path:
        -- executable = '/usr/local/bin/sudo',

        -- =====================================================================
        -- 调用方式
        -- Invocation mode
        -- =====================================================================

        -- 默认值：'auto'
        -- Default: 'auto'
        -- 'auto'  自动判断 sudo / sudo-rs / doas / 自定义命令
        -- 'auto'  auto-detect sudo / sudo-rs / doas / custom command
        -- 'sudo'  使用 sudo 的认证和参数
        -- 'sudo'  use sudo's authentication and arguments
        -- 'doas'  使用 doas 的参数
        -- 'doas'  use doas's arguments
        -- 'custom' 不在命令前添加任何参数，由包装脚本自行处理
        -- 'custom' prepend no arguments; let the wrapper script handle it
        -- flavor = 'auto',

        -- =====================================================================
        -- 认证
        -- Authentication
        -- =====================================================================

        -- 默认值：'Password: '
        -- Default: 'Password: '
        -- prompt = 'Password: ',

        -- 默认值：false
        -- Default: false
        -- true 表示永不提示密码，只使用已缓存的凭据或免密配置
        -- true means never prompt for a password; use only cached credentials or NOPASSWD config
        -- 对 sudo 使用 -n，对 doas 使用 -n
        -- Uses -n for sudo and -n for doas
        -- noninteractive = false,

        -- 默认值：nil（不超时）
        -- Default: nil (no timeout)
        -- 每个外部命令的超时时间，单位毫秒
        -- Timeout for each external command, in milliseconds
        -- 超时后命令会以 exit 124 失败
        -- On timeout the command fails with exit code 124
        -- timeout = 30000,

        -- 自定义密码输入函数
        -- Custom password input function
        -- 返回值必须是字符串；返回 nil 或空字符串表示取消
        -- Must return a string; returning nil or an empty string cancels
        -- prompt_password = function(prompt)
        --   return vim.fn.inputsecret(prompt)
        -- end,

        -- =====================================================================
        -- 功能开关
        -- Feature toggles
        -- =====================================================================

        -- 默认值：false
        -- Default: false
        -- 自动把不可读/不可写的文件切换为 suda:// 缓冲区
        -- Automatically switch unreadable/unwritable files to a suda:// buffer
        -- 例如 nvim /etc/hosts 或 :e /etc/shadow 会自动走 sudo
        -- e.g. nvim /etc/hosts or :e /etc/shadow will go through sudo automatically
        -- smart_edit = true,

        -- 默认值：true
        -- Default: true
        -- 写入成功后自动执行 :checktime，让其他 buffer 感知文件变化
        -- Run :checktime after a successful write so other buffers notice the change
        -- checktime = true,

        -- 默认值：false
        -- Default: false
        -- 在 vim.notify() 的 DEBUG 级别打印完整命令，便于排查问题
        -- Log the full command at vim.notify() DEBUG level for troubleshooting
        -- 不会打印密码
        -- Passwords are never printed
        -- debug = true,
        -- })
        -- end,
    },
}
