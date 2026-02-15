return {
  'rebelot/heirline.nvim',
  branch = 'master',
  dependencies = {
    { 'lewis6991/gitsigns.nvim', branch = 'main' }, -- Git状态支持
  },
  event = 'UIEnter',
  config = function()
    -- 插件加载容错
    local status_ok, heirline = pcall(require, 'heirline')
    if not status_ok then
      vim.notify('heirline.nvim 加载失败！', vim.log.levels.ERROR)
      return
    end

    local conditions = require('heirline.conditions')
    local utils = require('heirline.utils')

    -- ===================== 1. 颜色配置（自动适配主题） =====================
    local function setup_colors()
      local tokyo_colors = require('tokyonight.colors').setup({ transparent = true })
      return {
        bright_bg = tokyo_colors.bg_highlight,
        bright_fg = tokyo_colors.fg_dark,
        red = tokyo_colors.error,
        dark_red = tokyo_colors.diff.delete,
        green = tokyo_colors.green,
        blue = tokyo_colors.blue,
        -- gray = tokyo_colors.dark3,
        gray = tokyo_colors.comment,
        orange = tokyo_colors.orange,
        purple = tokyo_colors.purple,
        cyan = tokyo_colors.cyan,

        -- 直接用tokyonight诊断颜色
        diag_warn = tokyo_colors.warning,
        diag_error = tokyo_colors.error,
        diag_hint = tokyo_colors.hint,
        diag_info = tokyo_colors.info,

        -- Git颜色用tokyonight原生颜色
        git_del = tokyo_colors.git.delete,
        git_add = tokyo_colors.git.add,
        git_change = tokyo_colors.git.change,
      }
    end

    -- 加载颜色并监听主题切换
    local colors = setup_colors()
    heirline.load_colors(colors)
    vim.api.nvim_create_augroup('HeirlineColorGroup', { clear = true })
    vim.api.nvim_create_autocmd('ColorScheme', {
      group = 'HeirlineColorGroup',
      callback = function()
        utils.on_colorscheme(setup_colors)
      end,
    })

    -- ===================== 2. 基础组件与工具函数 =====================
    local Align = { provider = '%=' } -- 左右对齐分隔符
    local Space = { provider = ' ' } -- 空格分隔符
    local DefaultFileIcon = '󰈙' -- 默认文件图标

    -- 图标获取函数
    local function get_icon(category, target, fallback_icon)
      fallback_icon = fallback_icon or DefaultFileIcon

      -- 参数校验
      if type(category) ~= 'string' or category == '' or type(target) ~= 'string' or target == '' then
        return fallback_icon, 'DevIconDefault'
      end

      -- 插件容错
      local ok, mini_icons = pcall(require, 'mini.icons')
      if not ok then
        return fallback_icon, 'DevIconDefault'
      end

      local icon, hl = mini_icons.get(category, target)
      return icon or fallback_icon, hl or 'DevIconDefault'
    end

    -- ===================== 3. 核心组件定义 =====================
    -- 3.1 ViMode（模式指示器）
    local ViMode = {
      init = function(self)
        self.mode = vim.api.nvim_get_mode().mode -- 更精准的模式获取
      end,
      static = {
        -- 完整模式定义
        mode_names = {
          n = '普通',
          no = '普通?',
          nov = '普通?',
          noV = '普通?',
          ['no\22'] = '普通?',
          niI = '普通i',
          niR = '普通r',
          niV = '普通v',
          nt = '普通t',
          v = '可视',
          vs = '可视s',
          V = '可视行',
          Vs = '可视行s',
          ['\22'] = '可视块',
          ['\22s'] = '可视块s',
          s = '选择',
          S = '选择行',
          ['\19'] = '选择块',
          i = '插入',
          ic = '插入补全',
          ix = '插入补全',
          R = '替换',
          Rc = '替换补全',
          Rx = '替换补全',
          Rv = '可视替换',
          Rvc = '可视替换c',
          Rvx = '可视替换x',
          c = '命令',
          cv = 'Ex模式',
          r = '等待',
          rm = '更多',
          ['r?'] = '确认',
          ['!'] = '外壳',
          t = '终端',
        },
        mode_colors = {
          n = 'red',
          i = 'green',
          v = 'cyan',
          V = 'cyan',
          ['\22'] = 'cyan',
          c = 'orange',
          s = 'purple',
          S = 'purple',
          ['\19'] = 'purple',
          R = 'orange',
          r = 'orange',
          ['!'] = 'red',
          t = 'red',
        },
      },
      -- 固定宽度格式化
      provider = function(self)
        return ' %2(' .. (self.mode_names[self.mode] or '未知') .. '%)'
      end,
      hl = function(self)
        local mode = self.mode:sub(1, 1)
        return { fg = self.mode_colors[mode] or 'gray', bold = true }
      end,
      update = {
        'ModeChanged',
        pattern = '*:*',
        callback = vim.schedule_wrap(function()
          vim.cmd('redrawstatus')
        end),
      },
    }
    -- 美化ViMode
    ViMode = utils.surround({ '', '' }, 'bright_bg', { ViMode })

    -- 3.2 FileNameBlock（文件名称相关）
    local FileNameBlock = {
      init = function(self)
        self.filename = vim.api.nvim_buf_get_name(0)
      end,
    }

    -- WinBar文件图标
    local WinBarFileIcon = {
      init = function(self)
        self.filename = vim.api.nvim_buf_get_name(0)
        if self.filename == '' then
          self.icon, self.icon_hl = DefaultFileIcon, 'DevIconDefault'
          return
        end
        -- 优先按文件类型获取图标，失败则按文件名
        self.icon, self.icon_hl = get_icon(
          vim.bo.filetype ~= '' and 'filetype' or 'file',
          vim.bo.filetype ~= '' and vim.bo.filetype or self.filename
        )
      end,
      provider = function(self)
        return (self.icon or DefaultFileIcon) .. ' '
      end,
      hl = function(self)
        local icon_fg = utils.get_highlight(self.icon_hl or 'DevIconDefault').fg
        return { fg = icon_fg, bg = 'bright_bg', bold = true, force = true }
      end,
    }

    -- TabLine文件图标
    local TablineFileIcon = {
      init = function(self)
        local buf_buftype = vim.api.nvim_get_option_value('buftype', { buf = self.bufnr })
        if buf_buftype == 'terminal' then
          self.icon = '' -- 强制设置终端图标为
          self.icon_hl = 'DevIconDefault' -- 沿用默认图标高亮样式
          return -- 直接返回，不走后面的文件图标逻辑
        end
        -- 每个Buffer的文件名（已正确绑定self.bufnr）
        self.filename = vim.api.nvim_buf_get_name(self.bufnr)
        -- 每个Buffer自身的文件类型（关键修改）
        self.filetype = vim.api.nvim_get_option_value('filetype', { buf = self.bufnr })

        if self.filename == '' then
          self.icon, self.icon_hl = DefaultFileIcon, 'DevIconDefault'
          return
        end
        -- 基于当前Buffer的filetype/文件名获取图标
        self.icon, self.icon_hl =
          get_icon(self.filetype ~= '' and 'filetype' or 'file', self.filetype ~= '' and self.filetype or self.filename)
      end,
      provider = function(self)
        return (self.icon or DefaultFileIcon) .. ' '
      end,
      hl = function(self)
        local parent_bg = self.is_active and utils.get_highlight('TabLineSel').bg or utils.get_highlight('TabLine').bg
        local icon_fg = utils.get_highlight(self.icon_hl or 'DevIconDefault').fg
        return { fg = icon_fg, bg = parent_bg, bold = true, force = true }
      end,
    }

    -- 文件名
    local FileName = {
      init = function(self)
        -- :p 绝对路径，:.相对路径
        self.lfilename = self.filename == '' and '临时文件' or vim.fn.fnamemodify(self.filename, ':p')
      end,
      hl = { fg = utils.get_highlight('Directory').fg },
      flexible = 3, -- 更高优先级的灵活适配
      {
        provider = function(self)
          return self.lfilename
        end,
      },
      {
        provider = function(self)
          return vim.fn.pathshorten(self.lfilename)
        end,
      },
      { provider = '临时文件' },
    }

    -- 文件状态标记
    local FileFlags = {
      {
        condition = function()
          return vim.bo.modified
        end,
        provider = '[+]',
        hl = { fg = 'green' },
      },
      {
        condition = function()
          return not vim.bo.modifiable or vim.bo.readonly
        end,
        provider = '',
        hl = { fg = 'orange' },
      },
    }

    -- 文件名修饰
    local FileNameModifer = {
      hl = function()
        if vim.bo.modified then
          return { fg = 'cyan', bold = true, force = true }
        end
      end,
    }

    -- 组装FileNameBlock
    FileNameBlock = utils.insert(
      FileNameBlock,
      WinBarFileIcon,
      utils.insert(FileNameModifer, FileName),
      FileFlags,
      { provider = '%<' } -- 截断过长文件名
    )

    -- 3.3 Git状态
    local GitContent = {
      -- 初始化：直接读取 gitsigns 提供的变量
      init = function(self)
        self.status_dict = vim.b.gitsigns_status_dict
        self.head = vim.b.gitsigns_head or '未知分支'
      end,
      -- 分支部分：单独做成子组件，设置 orange
      {
        hl = { fg = 'orange', bold = true, force = true }, -- 分支名单独设 orange
        { provider = ' ' },
        {
          provider = function(self)
            local head = self.head
            if #head > 15 then
              head = vim.fn.strcharpart(head, 0, 12) .. '...'
            end
            return head
          end,
        },
      },
      -- 中间变更容器：无需额外设置 hl，因为外层没有 fg 了
      {
        condition = function(self)
          return self.status_dict
            and (self.status_dict.added or 0) + (self.status_dict.changed or 0) + (self.status_dict.removed or 0) > 0
        end,
        provider = ' · ',
        -- 内层变更项（保持原有配置，已加 force = true）
        {
          condition = function(self)
            return (self.status_dict.added or 0) > 0
          end,
          provider = function(self)
            return '+' .. self.status_dict.added .. ' '
          end,
          hl = { fg = 'git_add', bold = true, force = true },
        },
        {
          condition = function(self)
            return (self.status_dict.changed or 0) > 0
          end,
          provider = function(self)
            return '~' .. self.status_dict.changed .. ' '
          end,
          hl = { fg = 'git_change', bold = true, force = true },
        },
        {
          condition = function(self)
            return (self.status_dict.removed or 0) > 0
          end,
          provider = function(self)
            return '-' .. self.status_dict.removed .. ' '
          end,
          hl = { fg = 'git_del', bold = true, force = true },
        },
      },
      -- 自动更新
      update = { 'BufEnter', 'BufWritePost', 'FocusGained' },
    }
    local Git = {
      -- 条件判断：只有 Git 仓库才渲染
      condition = function()
        return vim.b.gitsigns_status_dict or vim.b.gitsigns_head
      end,
      -- 嵌套带边框的 GitContent
      utils.surround({ '', '' }, 'bright_bg', { GitContent }),
    }

    -- 3.4 调试
    local Diagnostics = {
      condition = conditions.has_diagnostics,
      init = function(self)
        -- 直接复用全局诊断配置的 text 图标（来自 mini.lua 的 mini.icons）
        local signs_text = vim.diagnostic.config().signs.text or {}

        self.icons = {
          Error = signs_text[vim.diagnostic.severity.ERROR] or ' ',
          Warn = signs_text[vim.diagnostic.severity.WARN] or ' ',
          Info = signs_text[vim.diagnostic.severity.INFO] or ' ',
          Hint = signs_text[vim.diagnostic.severity.HINT] or ' ',
        }

        self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
        self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
        self.infos = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
        self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
      end,
      update = { 'DiagnosticChanged', 'BufEnter' },

      {
        provider = function(self)
          return self.errors > 0 and (self.icons.Error .. self.errors .. ' ')
        end,
        hl = { fg = 'diag_error' },
      },
      {
        provider = function(self)
          return self.warnings > 0 and (self.icons.Warn .. self.warnings .. ' ')
        end,
        hl = { fg = 'diag_warn' },
      },
      {
        provider = function(self)
          return self.infos > 0 and (self.icons.Info .. self.infos .. ' ')
        end,
        hl = { fg = 'diag_info' },
      },
      {
        provider = function(self)
          return self.hints > 0 and (self.icons.Hint .. self.hints)
        end,
        hl = { fg = 'diag_hint' },
      },
    }

    -- 3.5 LSP活跃状态（延迟调用）
    local LSPActive = {
      condition = conditions.lsp_attached,
      update = { 'LspAttach', 'LspDetach' },
      provider = function()
        local names = vim.tbl_map(function(s)
          return s.name
        end, vim.lsp.get_clients({ bufnr = 0 }))
        local name_str = table.concat(names, ', ')
        -- 截断过长的LSP名称（最多显示20个字符，超出部分用...代替）
        if #name_str > 20 then
          name_str = vim.fn.strcharpart(name_str, 0, 17) .. '...'
        end
        return #names > 0 and ('[' .. name_str .. ']')
      end,
      hl = { fg = 'green', bold = true },
      on_click = {
        -- 延迟调用避免卡顿
        callback = function()
          vim.defer_fn(function()
            vim.cmd('LspInfo')
          end, 100)
        end,
        name = 'heirline_lsp',
      },
    }

    -- 3.6 光标位置与滚动条
    local Ruler = {
      -- 显示行/总行:列 进度
      provider = '%l/%L:%c %P',
    }

    -- 3.7 文件类型
    local FileType = {
      init = function(self)
        if vim.bo.buftype == 'terminal' then
          self.filetype = 'Terminal'
          self.icon, self.icon_hl = get_icon('filetype', 'terminal') -- 用终端专属图标
          return
        end
        self.filetype = vim.bo.filetype
        if self.filetype == '' then
          self.icon, self.icon_hl = DefaultFileIcon, 'DevIconDefault'
          return
        end
        self.icon, self.icon_hl = get_icon('filetype', self.filetype)
      end,
      provider = function(self)
        local ft = self.filetype == '' and 'unknown' or self.filetype:upper()
        return (self.icon or DefaultFileIcon) .. ' ' .. ft
      end,
      hl = function(self)
        local status_bg = conditions.is_active() and utils.get_highlight('StatusLine').bg
          or utils.get_highlight('StatusLineNC').bg
        local icon_fg = utils.get_highlight(self.icon_hl or 'DevIconDefault').fg
        return { fg = icon_fg, bg = status_bg, bold = true, force = true }
      end,
    }

    -- 3.8 文件格式与系统风格
    local FileFormat = {
      init = function(self)
        -- 获取文件的核心格式信息
        self.fileformat = vim.bo.fileformat -- unix/dos/mac（系统风格）
        self.fileencoding = vim.bo.fileencoding or vim.o.encoding -- 字符编码（如UTF-8）
        self.fileformat_icon = { -- 系统风格图标映射
          unix = '', -- Unix/Linux/Mac
          dos = '', -- Windows
          mac = '', -- 旧版Mac
        }
        self.eol_icon = { -- 换行符图标映射
          unix = 'LF',
          dos = 'CRLF',
          mac = 'CR',
        }
      end,
      provider = function(self)
        -- 显示格式：「系统图标 + 换行符 + 编码」（可自定义组合）
        local fmt = self.fileformat_icon[self.fileformat] or ''
        local eol = self.eol_icon[self.fileformat] or '?'
        local enc = self.fileencoding:upper()
        return fmt .. ' ' .. eol .. ' ' .. enc
      end,
      hl = { fg = 'purple', bold = true },
    }

    -- 3.9 LSP 面包屑
    local Navic = {
      condition = function()
        local ok, navic = pcall(require, 'nvim-navic')
        return ok and navic.is_available()
      end,
      provider = function()
        return require('nvim-navic').get_location()
      end,
      update = { 'CursorMoved', 'CursorMovedI', 'BufEnter' },
      hl = { fg = 'gray', italic = true },
    }

    -- ===================== 4. 组装 StatusLine（状态线） =====================
    local DefaultStatusline = {
      ViMode,
      Space,
      Git,
      Space,
      Diagnostics,
      Navic,
      Align,
      Space,
      LSPActive,
      Space,
      FileFormat,
      Space,
      FileType,
      Space,
      Ruler,
    }

    local InactiveStatusline = {
      condition = conditions.is_not_active,
      hl = { fg = 'gray', bg = 'StatusLineNC', force = true },
      FileType,
      Space,
      FileNameBlock,
      Align,
    }

    local SpecialStatusline = {
      condition = function()
        return conditions.buffer_matches({
          buftype = { 'nofile', 'prompt', 'help', 'quickfix' },
          filetype = { '^git.*', 'fugitive' },
        })
      end,
      FileType,
      Space,
      {
        condition = function()
          return vim.bo.filetype == 'help'
        end,
        provider = function()
          return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':t')
        end,
        hl = { fg = 'blue' },
      },
      Align,
    }

    local TerminalStatusline = {
      condition = function()
        return vim.bo.buftype == 'terminal'
      end,
      hl = function()
        local status_bg = conditions.is_active() and utils.get_highlight('StatusLine').bg
          or utils.get_highlight('StatusLineNC').bg
        return { bg = status_bg, force = true }
      end,
      -- 仅活跃时显示ViMode
      { condition = conditions.is_active, ViMode, Space },
      {
        provider = function()
          local shell_name = vim.env.SHELL:match('[/\\]([%w%-]+)%.?%w*$') or 'Shell'
          return ' 终端 ' .. shell_name
        end,
        hl = { fg = 'blue', bold = true },
      },
      Align,
    }

    local StatusLines = {
      hl = function()
        return conditions.is_active() and 'StatusLine' or 'StatusLineNC'
      end,
      fallthrough = false,
      SpecialStatusline,
      TerminalStatusline,
      InactiveStatusline,
      DefaultStatusline,
    }

    -- ===================== 5. 组装 WinBar（窗口顶部导航栏） =====================
    -- 先抽离公共 WinBar 组件（单独定义，返回组件结构）
    local function get_common_winbar(fg_color)
      return {
        { provider = '  ' },
        utils.surround({ '', '' }, 'bright_bg', {
          hl = {
            fg = fg_color,
            bg = 'bright_bg',
            force = true,
          },
          FileNameBlock,
        }),
      }
    end

    -- 组装 WinBars（直接引用公共组件，不通过 provider 函数）
    local WinBars = {
      fallthrough = false,
      -- 1. 终端窗口：隐藏 WinBar
      {
        condition = function()
          return vim.bo.buftype == 'terminal'
        end,
        provider = '',
      },
      -- 2. 非活跃窗口：引用公共组件，传入 gray
      utils.insert({ condition = conditions.is_not_active }, get_common_winbar('gray')),
      -- 3. 活跃窗口：引用公共组件，传入 nil
      get_common_winbar(nil),
    }

    -- ===================== 6. 组装 TabLine（标签栏/缓冲区栏） =====================
    local TablineFileNameBlock = {
      init = function(self)
        self.filename = vim.api.nvim_buf_get_name(self.bufnr)
        self.is_terminal = vim.api.nvim_get_option_value('buftype', { buf = self.bufnr }) == 'terminal'
      end,
      hl = function(self)
        local base_hl = self.is_active and utils.get_highlight('TabLineSel') or utils.get_highlight('TabLine')
        return {
          fg = base_hl.fg,
          bg = base_hl.bg,
          bold = self.is_active or self.is_visible,
          italic = true,
          force = true,
        }
      end,
      on_click = {
        callback = function(_, minwid, _, button)
          if button == 'm' then
            vim.schedule(function()
              vim.api.nvim_buf_delete(minwid, { force = false })
            end) -- 延迟删除
          else
            vim.api.nvim_win_set_buf(0, minwid)
          end
        end,
        minwid = function(self)
          return self.bufnr
        end,
        name = 'heirline_tabline_buffer_callback',
      },
      {
        provider = function(self)
          return tostring(self.bufnr) .. '. '
        end,
        hl = 'Comment',
      },
      TablineFileIcon,
      {
        provider = function(self)
          if self.is_terminal then
            return 'Terminal'
          end
          return self.filename == '' and '临时文件' or vim.fn.fnamemodify(self.filename, ':t')
        end,
      },
      {
        condition = function(self)
          return vim.api.nvim_get_option_value('modified', { buf = self.bufnr })
        end,
        provider = '[+]',
        hl = { fg = 'green' },
      },
    }

    -- 缓冲区块（滚动箭头）
    local TablineBufferBlock = utils.surround(
      -- { ' │ ', '' }, -- 简洁分隔
      { '  ', '' }, -- 简洁分隔
      function(self)
        return self.is_active and utils.get_highlight('TabLineSel').bg or utils.get_highlight('TabLine').bg
      end,
      { TablineFileNameBlock }
    )

    -- 缓冲区列表（支持滚动）
    local BufferLine = utils.make_buflist(
      TablineBufferBlock,
      { provider = '', hl = { fg = 'gray' } }, -- 左滚动箭头
      { provider = '', hl = { fg = 'gray' } } -- 右滚动箭头
    )

    -- 标签页
    local TabPages = {
      condition = function()
        return #vim.api.nvim_list_tabpages() >= 2
      end,
      Align,
      utils.make_tablist({
        provider = function(self)
          return '%' .. self.tabnr .. 'T ' .. self.tabpage .. ' %T'
        end,
        hl = function(self)
          return self.is_active and 'TabLineSel' or 'TabLine'
        end,
      }),
    }

    -- 组装TabLine
    local TabLine = {
      BufferLine,
      TabPages,
      update = { -- 显式更新事件
        'TabNew',
        'TabClosed',
        'TabEnter',
        'BufEnter',
        'BufLeave',
        callback = vim.schedule_wrap(function()
          vim.cmd('redrawtabline')
        end),
      },
    }

    -- ===================== 7. 最终初始化 + 额外优化 =====================
    heirline.setup({
      statusline = StatusLines,
      winbar = WinBars,
      tabline = TabLine,
      opts = {
        disable_winbar_cb = function(args)
          return conditions.buffer_matches({
            buftype = { 'nofile', 'prompt', 'help', 'quickfix', 'terminal' },
            filetype = { '^git.*', 'fugitive', 'Trouble', 'dashboard' },
          }, args.buf)
        end,
      },
    })

    -- 强制显示TabLine
    vim.opt.showtabline = 2

    -- 隐藏冗余缓冲区
    vim.api.nvim_create_augroup('HeirlineHiddenBuffers', { clear = true })
    vim.api.nvim_create_autocmd('FileType', {
      group = 'HeirlineHiddenBuffers',
      callback = function()
        local bufhidden = vim.bo.bufhidden
        if bufhidden == 'wipe' or bufhidden == 'delete' then
          vim.bo.buflisted = false
        end
      end,
    })
  end,
}
