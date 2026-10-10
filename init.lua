-- ============================================================
-- 第一节：选项配置
-- Neovim 核心设置，leader 键，各类选项
-- ============================================================
do
  -- 通过缓存编译后的 Lua 模块来加速启动
  vim.loader.enable()

  -- 设置 <空格> 为 leader 键
  -- 查看 `:help mapleader`
  --  注意：必须在加载插件之前设置（否则会使用错误的 leader）
  vim.g.mapleader = ' '
  vim.g.maplocalleader = ' '

  -- 如果你安装并在终端中选择了 Nerd Font，就设置为 true
  vim.g.have_nerd_font = true

  -- [[ 设置选项 ]]
  --  查看 `:help vim.o`
  -- 注意：你可以根据自己的喜好更改这些选项！
  --  更多选项，请查看 `:help option-list`

  -- 默认显示行号
  vim.o.number = true
  vim.o.relativenumber = true

  -- 开启鼠标支持，比如调整分屏大小的时候会很有用！
  vim.o.mouse = 'a'

  -- 不显示模式信息，因为状态栏已经显示了
  vim.o.showmode = false

  -- 在操作系统和 Neovim 之间同步剪贴板。
  --  在 `UiEnter` 之后再设置，因为它会增加启动时间。
  --  如果你希望操作系统剪贴板保持独立，请删除此选项。
  --  查看 `:help 'clipboard'`
  vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

  -- 开启折行缩进
  vim.o.breakindent = true

  -- 即使关闭并重新打开文件，也支持撤销/重做修改
  vim.o.undofile = true

  -- 搜索不区分大小写，除非使用 \C 或搜索词中有一个或多个大写字母
  vim.o.ignorecase = true
  vim.o.smartcase = true

  -- 默认保持显示签名列
  vim.o.signcolumn = 'yes'

  -- 减少更新时间
  vim.o.updatetime = 250

  -- 减少映射序列等待时间
  vim.o.timeoutlen = 300

  -- 配置新分屏的打开方式
  vim.o.splitright = true
  vim.o.splitbelow = true

  -- 设置 neovim 如何在编辑器中显示某些空白字符。
  --  查看 `:help 'list'`
  --  和 `:help 'listchars'`
  --
  --  注意 listchars 是使用 `vim.opt` 而不是 `vim.o` 设置的。
  --  它和 `vim.o` 非常相似，但提供了一个方便操作表的接口。
  --   查看 `:help lua-options`
  --   和 `:help lua-guide-options`
  vim.o.list = true
  vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

  -- 实时预览替换，边输入边预览！
  vim.o.inccommand = 'split'

  -- 显示光标所在行
  vim.o.cursorline = true

  -- 光标上下保持最少的屏幕行数。
  vim.o.scrolloff = 10

  -- 如果因为缓冲区有未保存的更改导致操作失败（比如 `:q`），
  -- 弹出对话框询问你是否要保存当前文件
  -- 查看 `:help 'confirm'`
  vim.o.confirm = true
end

-- ============================================================
-- 第二节：快捷键与自动命令
-- 基础快捷键，基础自动命令
-- ============================================================
do
  -- [[ 基础快捷键 ]]
  --  查看 `:help vim.keymap.set()`

  -- 普通模式下按 <ESC> 清除搜索高亮
  --  查看 `:help hlsearch`
  vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

  -- 诊断配置与快捷键
  --  查看 `:help vim.diagnostic.Opts`
  vim.diagnostic.config {
    update_in_insert = false,
    severity_sort = true,
    float = { border = 'rounded', source = 'if_many' },
    underline = { severity = { min = vim.diagnostic.severity.WARN } },

    -- 你可以根据偏好选择其中一种
    virtual_text = true, -- 文本显示在行末
    virtual_lines = false, -- 文本显示在下方，使用虚拟行

    -- 自动打开浮动窗口，所以当你用 `[d` 和 `]d` 跳转错误时可以轻松阅读
    jump = {
      on_jump = function(_, bufnr)
        vim.diagnostic.open_float {
          bufnr = bufnr,
          scope = 'cursor',
          focus = false,
        }
      end,
    },
  }

  vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = '打开诊断快速修复列表' })

  -- 用一个更容易发现的快捷键退出内置终端的终端模式。
  -- 否则通常需要按 <C-\><C-n>，没有经验的人一般猜不到。
  --
  -- 注意：这在所有终端模拟器/tmux 等中都不起作用。试试你自己的映射，
  -- 或者直接使用 <C-\><C-n> 退出终端模式
  vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = '退出终端模式' })


  -- 快捷键让分屏导航更容易。
  --  使用 CTRL+<hjkl> 在窗口之间切换
  --
  --  查看 `:help wincmd` 获取所有窗口命令列表
  vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = '将焦点移动到左侧窗口' })
  vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = '将焦点移动到右侧窗口' })
  vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = '将焦点移动到下方窗口' })
  vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = '将焦点移动到上方窗口' })

  -- 注意：有些终端的按键冲突，或者无法发送不同的键码
  -- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "将窗口移动到左侧" })
  -- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "将窗口移动到右侧" })
  -- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "将窗口移动到下方" })
  -- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "将窗口移动到上方" })

  -- [[ 基础自动命令 ]]
  --  查看 `:help lua-guide-autocommands`

  -- 复制（yanking）文本时高亮
  --  在普通模式试试 `yap` 看看效果
  --  查看 `:help vim.hl.on_yank()`
  vim.api.nvim_create_autocmd('TextYankPost', {
    desc = '复制文本时高亮',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function() vim.hl.on_yank() end,
  })
end

-- ============================================================
-- 第三节：插件管理器介绍
-- vim.pack 介绍，构建钩子
-- ============================================================
do
  -- [[ `vim.pack` 介绍 ]]
  -- `vim.pack` 是 Neovim 内置的新插件管理器，
  --  它提供了一个用于安装和管理插件的 Lua 接口。
  --
  --  查看 `:help vim.pack`、`:help vim.pack-examples`，
  --  或者查看 vim.pack 和 mini.nvim 创建者的优秀博客文章：
  --  https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack
  --
  --  要检查插件状态和待处理的更新，请运行
  --    :lua vim.pack.update(nil, { offline = true })
  --
  --  要更新插件，请运行
  --    :lua vim.pack.update()
  --
  --
  -- 在配置的其余部分，会有如何使用 `vim.pack` 安装和配置插件的示例。
  --
  -- 在本节中，我们设置了一些自动命令，在某些插件安装或更新后运行构建步骤。

  local function run_build(name, cmd, cwd)
    local result = vim.system(cmd, { cwd = cwd }):wait()
    if result.code ~= 0 then
      local stderr = result.stderr or ''
      local stdout = result.stdout or ''
      local output = stderr ~= '' and stderr or stdout
      if output == '' then output = '构建命令没有输出。' end
      vim.notify(('%s 构建失败：\n%s'):format(name, output), vim.log.levels.ERROR)
    end
  end

  -- 这个自动命令在插件安装或更新后运行，
  --  如果需要，为该插件运行适当的构建命令。
  --
  -- 查看 `:help vim.pack-events`
  vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
      local name = ev.data.spec.name
      local kind = ev.data.kind
      if kind ~= 'install' and kind ~= 'update' then return end

      if name == 'telescope-fzf-native.nvim' and vim.fn.executable 'make' == 1 then
        run_build(name, { 'make' }, ev.data.path)
        return
      end

      if name == 'LuaSnip' then
        if vim.fn.has 'win32' ~= 1 and vim.fn.executable 'make' == 1 then run_build(name, { 'make', 'install_jsregexp' }, ev.data.path) end
        return
      end

      if name == 'nvim-treesitter' then
        if not ev.data.active then vim.cmd.packadd 'nvim-treesitter' end
        vim.cmd 'TSUpdate'
        return
      end
    end,
  })
end

--- 因为大多数插件都托管在 GitHub 上，所以你可以使用这个辅助函数来减少下面章节中的重复代码。
---@param repo string
---@return string
local function gh(repo) return 'https://github.com/' .. repo end

-- ============================================================
-- 第四节：UI / 核心用户体验插件
-- guess-indent, gitsigns, which-key, colorscheme, todo-comments, mini 模块
-- ============================================================
do
  -- [[ 安装和配置插件 ]]
  --
  -- 要安装插件，只需使用 git 地址调用 `vim.pack.add`。
  -- 这会下载插件的默认分支，通常是 `main` 或 `master`
  -- 你也可以使用更高级的配置，我们后面会说到。
  --
  -- 大多数插件只安装还不够，你还需要调用它们的 `.setup()` 来启动它们。
  --
  -- 例如，假设我们想安装 `guess-indent.nvim` - 一个自动检测并设置缩进的插件。
  --
  -- 我们先从 https://github.com/NMAC427/guess-indent.nvim 安装它，
  -- 然后调用它的 `setup()` 函数使用默认设置启动。
  vim.pack.add { gh 'NMAC427/guess-indent.nvim' }
  require('guess-indent').setup {}

  -- 这是一个更高级的配置示例，将选项传递给 `gitsigns.nvim`
  --
  -- 查看 `:help gitsigns` 了解每个配置键的作用。
  -- 在侧边栏添加 git 相关标记，以及管理变更的工具
  vim.pack.add { gh 'lewis6991/gitsigns.nvim' }
  local gitsigns = require 'gitsigns'
  gitsigns.setup {
    signs = {
      add = { text = '+' }, ---@diagnostic disable-line: missing-fields
      change = { text = '~' }, ---@diagnostic disable-line: missing-fields
      delete = { text = '_' }, ---@diagnostic disable-line: missing-fields
      topdelete = { text = '‾' }, ---@diagnostic disable-line: missing-fields
      changedelete = { text = '~' }, ---@diagnostic disable-line: missing-fields
    },
    -- gitsigns.nvim 推荐快捷键:
    on_attach = function(bufnr)
      -- 导航
      vim.keymap.set('n', ']c', function()
        if vim.wo.diff then
          vim.cmd.normal { ']c', bang = true }
        else
          gitsigns.nav_hunk 'next'
        end
      end, { desc = '下一个 git 变更', buf = bufnr })

      vim.keymap.set('n', '[c', function()
        if vim.wo.diff then
          vim.cmd.normal { '[c', bang = true }
        else
          gitsigns.nav_hunk 'prev'
        end
      end, { desc = '上一个 git 变更', buf = bufnr })

      -- 可视模式操作
      vim.keymap.set('v', '<leader>hs', function() gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' } end, { desc = 'git 暂存块', buf = bufnr })
      vim.keymap.set('v', '<leader>hr', function() gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' } end, { desc = 'git 重置块', buf = bufnr })
      -- 普通模式操作
      vim.keymap.set('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'git 暂存块', buf = bufnr })
      vim.keymap.set('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'git 重置块', buf = bufnr })
      vim.keymap.set('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'git 暂存缓冲区', buf = bufnr })
      vim.keymap.set('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'git 重置缓冲区', buf = bufnr })
      vim.keymap.set('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'git 预览块', buf = bufnr })
      vim.keymap.set('n', '<leader>hi', gitsigns.preview_hunk_inline, { desc = 'git 行内预览块', buf = bufnr })
      vim.keymap.set('n', '<leader>hb', function() gitsigns.blame_line { full = true } end, { desc = 'git 行责认', buf = bufnr })
      vim.keymap.set('n', '<leader>hd', gitsigns.diffthis, { desc = 'git 对比索引差异', buf = bufnr })
      vim.keymap.set('n', '<leader>hD', function() gitsigns.diffthis '~' end, { desc = 'git 对比上次提交差异', buf = bufnr })
      vim.keymap.set('n', '<leader>hQ', function() gitsigns.setqflist 'all' end, { desc = 'git 块快速修复列表 (仓库所有文件)', buf = bufnr })
      vim.keymap.set('n', '<leader>hq', gitsigns.setqflist, { desc = 'git 块快速修复列表 (当前文件所有变更)', buf = bufnr })
      -- 开关
      vim.keymap.set('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = '切换 git 显示行责认', buf = bufnr })
      vim.keymap.set('n', '<leader>tw', gitsigns.toggle_word_diff, { desc = '切换 git 行内单词差异', buf = bufnr })
      -- 文本对象
      vim.keymap.set({ 'o', 'x' }, 'ih', gitsigns.select_hunk, { desc = '文本对象 块内', buf = bufnr })
    end,
  }

  -- 一个用来显示待按下按键的实用插件。
  vim.pack.add { gh 'folke/which-key.nvim' }
  require('which-key').setup {
    -- 按下按键和打开 which-key 之间的延迟（毫秒）
    delay = 0,
    icons = { mappings = vim.g.have_nerd_font },
    -- 记录现有按键链
    spec = {
      { '<leader>s', group = '搜索', mode = { 'n', 'v' } },
      { '<leader>t', group = '切换' },
      { '<leader>h', group = 'Git 块', mode = { 'n', 'v' } }, -- 先启用 gitsigns 推荐快捷键
      { 'gr', group = 'LSP 操作', mode = { 'n' } },
    },
  }

  -- [[ 颜色方案 ]]
  -- 你可以轻松更改成不同的颜色方案。
  -- 修改下方颜色方案插件的名称，然后修改下面的命令来加载你想要的颜色方案。
  --
  -- 如果你想查看已经安装了哪些颜色方案，可以使用 `:Telescope colorscheme`。
  vim.pack.add { gh 'folke/tokyonight.nvim' }
  ---@diagnostic disable-next-line: missing-fields
  require('tokyonight').setup {
    styles = {
      comments = { italic = false }, -- 禁止注释斜体
    },
  }

  -- 在这里加载颜色方案。
  -- 和许多其他主题一样，这个主题有不同的风格，你可以加载任何其他风格，
  -- 比如 'tokyonight-storm', 'tokyonight-moon', 或者 'tokyonight-day'。
  vim.cmd.colorscheme 'tokyonight-night'

  -- 高亮注释中的 todo、notes 等
  vim.pack.add { gh 'folke/todo-comments.nvim' }
  require('todo-comments').setup { signs = false }

  -- [[ mini.nvim ]]
  --  各种小型独立插件/模块的集合
  vim.pack.add { gh 'nvim-mini/mini.nvim' }

  -- 如果有 Nerd Font，加载图标模块，在各种插件中显示漂亮的图标。
  if vim.g.have_nerd_font then
    require('mini.icons').setup()
    -- 用于向后兼容需要 `nvim-web-devicons` 的插件（比如 telescope.nvim）
    MiniIcons.mock_nvim_web_devicons()
  end

  -- 更好的文本对象外围/内部支持
  --
  -- 示例:
  --  - va)  - 可视选择外围括号
  --  - yiiq - 复制引号内部内容
  --  - ci'  - 修改引号内部内容
  require('mini.ai').setup {
    -- 注意：避免与 Neovim>=0.12 内置增量选择映射冲突 (查看 `:help treesitter-incremental-selection`)
    mappings = {
      around_next = 'aa',
      inside_next = 'ii',
    },
    n_lines = 500,
  }

  -- 添加/删除/替换环绕符号（括号、引号等）
  --
  -- - saiw) - 在单词外部添加括号环绕
  -- - sd'   - 删除引号环绕
  -- - sr)'  - 将括号环绕替换成引号
  require('mini.surround').setup()

  -- 简单易用的状态栏。
  --  如果你不喜欢，可以删除这个 setup 调用，试试其他状态栏插件
  local statusline = require 'mini.statusline'
  -- 如果你有 Nerd Font，设置 `use_icons` 为 true
  statusline.setup { use_icons = vim.g.have_nerd_font }

  -- 你可以通过覆盖默认行为来配置状态栏中的各个部分。
  -- 例如，这里我们将光标位置部分设置为 行:列
  ---@diagnostic disable-next-line: duplicate-set-field
  statusline.section_location = function() return '%2l:%-2v' end

  -- ... 还有更多功能！
  --  查看: https://github.com/nvim-mini/mini.nvim
end

-- ============================================================
-- 第五节：搜索与导航
-- Telescope 配置，快捷键，LSP 选择器映射
-- ============================================================
do
  -- [[ 模糊查找器（文件、LSP 等） ]]
  --
  -- Telescope 是一个模糊查找器，它可以模糊查找很多不同的东西。
  -- 它不仅仅是一个"文件查找器"，它可以搜索 Neovim、你的工作区、LSP
  -- 等等许多不同方面的内容！
  --
  -- 还有许多其他替代的选择器（比如 snacks.picker 或 fzf-lua），
  -- 所以尽管去实验，找到你喜欢的！
  --
  -- 使用 Telescope 最简单的方法，就是从这样开始:
  --  :Telescope help_tags
  --
  -- 运行这个命令后，会打开一个窗口，你可以在提示窗口中输入。
  -- 你会看到一个 `help_tags` 选项列表，以及相应的帮助预览。
  --
  -- 在 Telescope 中使用的两个重要快捷键:
  --  - 插入模式: <c-/>
  --  - 普通模式: ?
  --
  -- 这会打开一个窗口，显示当前 Telescope 选择器的所有快捷键。
  -- 这对于发现 Telescope 可以做什么，以及如何实际操作非常有用！

  ---@type (string | vim.pack.Spec)[]
  local telescope_plugins = {
    gh 'nvim-lua/plenary.nvim',
    gh 'nvim-telescope/telescope.nvim',
    gh 'nvim-telescope/telescope-ui-select.nvim',
  }
  if vim.fn.executable 'make' == 1 then table.insert(telescope_plugins, gh 'nvim-telescope/telescope-fzf-native.nvim') end

  -- 注意：你可以一次性安装多个插件
  vim.pack.add(telescope_plugins)

  -- 查看 `:help telescope` 和 `:help telescope.setup()`
  require('telescope').setup {
    -- 你可以把你的默认映射/更新等放在这里
    --  你寻找的所有信息都在 `:help telescope.setup()` 里
    --
    -- defaults = {
    --   mappings = {
    --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
    --   },
    -- },
    -- pickers = {}
    extensions = {
      ['ui-select'] = { require('telescope.themes').get_dropdown() },
    },
  }

  -- 如果安装了 Telescope 扩展，就启用它们
  pcall(require('telescope').load_extension, 'fzf')
  pcall(require('telescope').load_extension, 'ui-select')

  -- 查看 `:help telescope.builtin`
  local builtin = require 'telescope.builtin'
  vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '搜索帮助' })
  vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '搜索快捷键' })
  vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '搜索文件' })
  vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '搜索选择 Telescope' })
  vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = '搜索当前单词' })
  vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '实时 Grep 搜索' })
  vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '搜索诊断' })
  vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '恢复搜索' })
  vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '搜索最近文件' })
  vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = '搜索命令' })
  vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '查找已存在缓冲区' })

  -- 当 LSP 附加到缓冲区时，添加基于 Telescope 的 LSP 选择器。
  -- 如果你之后切换选择器插件，在这里更新这些映射。
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
    callback = function(event)
      local buf = event.buf

      -- 查找光标下单词的引用。
      vim.keymap.set('n', 'grr', builtin.lsp_references, { buffer = buf, desc = '转到引用' })

      -- 跳转到光标下单词的实现。
      -- 当你的语言可以在没有实际实现的情况下声明类型时，这很有用。
      vim.keymap.set('n', 'gri', builtin.lsp_implementations, { buffer = buf, desc = '转到实现' })

      -- 跳转到光标下单词的定义。
      -- 这就是变量第一次声明的地方，函数定义的地方，等等。
      -- 要返回，按 <C-t>。
      vim.keymap.set('n', 'grd', builtin.lsp_definitions, { buffer = buf, desc = '转到定义' })

      -- 模糊查找当前文档中的所有符号。
      -- 符号就是变量、函数、类型等。
      vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, { buffer = buf, desc = '打开文档符号' })

      -- 模糊查找当前工作区中的所有符号。
      -- 和文档符号类似，只不过搜索整个项目。
      vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = '打开工作区符号' })

      -- 跳转到光标下单词的类型。
      -- 当你不确定变量是什么类型，想要看它的类型定义而不是它在哪里定义时，这很有用。
      vim.keymap.set('n', 'grt', builtin.lsp_type_definitions, { buffer = buf, desc = '转到类型定义' })
    end,
  })

  -- 搜索时覆盖默认行为和主题
  vim.keymap.set('n', '<leader>/', function()
    -- 你可以给 Telescope 传递额外的配置来改变主题、布局等。
    builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
      winblend = 10,
      previewer = false,
    })
  end, { desc = '[ / ] 在当前缓冲区模糊搜索' })

  -- 也可以传递额外的配置选项。
  --  查看 `:help telescope.builtin.live_grep()` 获取特定键的信息
  vim.keymap.set(
    'n',
    '<leader>s/',
    function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = '在打开文件中实时 Grep',
      }
    end,
    { desc = '[ S ] 搜索 [ / ] 打开文件' }
  )

  -- 搜索 Neovim 配置文件的快捷键
  vim.keymap.set('n', '<leader>sn', function() builtin.find_files { cwd = vim.fn.stdpath 'config', follow = true } end, { desc = '搜索 [ N ] eovim 文件' })
end

-- ============================================================
-- 第六节：LSP
-- LSP 快捷键，服务端配置，Mason 工具安装
-- ============================================================
do
  -- [[ LSP 配置 ]]
  -- 简短题外话：**什么是 LSP？**
  --
  -- LSP 是你可能听过的首字母缩写，但可能不知道它是什么。
  --
  -- LSP 代表语言服务器协议（Language Server Protocol）。它是一个帮助编辑器
  -- 和语言工具以标准化方式通信的协议。
  --
  -- 一般来说，你有一个"服务器"，它是一个理解特定语言的工具（比如 `gopls`、`lua_ls`、`rust_analyzer` 等）。
  -- 这些语言服务器（有时叫 LSP 服务器，就像 ATM 机一样，多说一次）是独立进程，
  -- 和"客户端"通信 - 在这个情况下客户端就是 Neovim！
  --
  -- LSP 为 Neovim 提供了以下功能:
  --  - 转到定义
  --  - 查找引用
  --  - 自动补全
  --  - 符号搜索
  --  - 还有更多！
  --
  -- 因此，语言服务器是必须与 Neovim 分开安装的外部工具。这就是 `mason`
  -- 和相关插件发挥作用的地方。
  --
  -- 如果你想知道 lsp 和 treesitter 的区别，你可以查看精彩简洁的帮助文档 `:help lsp-vs-treesitter`

  -- 为 LSP 提供有用的状态更新。
  vim.pack.add { gh 'j-hui/fidget.nvim' }
  require('fidget').setup {}

  --  当 LSP 附加到特定缓冲区时运行这个函数。
  --    也就是说，每次打开一个与 lsp 关联的新文件（例如，打开 `main.rs` 会关联 `rust_analyzer`），
  --    这个函数就会被执行，配置当前缓冲区
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
    callback = function(event)
      -- 注意：记住 Lua 是一个真正的编程语言，因此可以定义小的辅助工具函数，这样你就不必重复自己。
      --
      -- 在这种情况下，我们创建了一个函数，让我们可以更轻松地定义特定于 LSP 相关项目的映射。
      -- 它每次都会为我们设置模式、缓冲区和描述。
      local map = function(keys, func, desc, mode)
        mode = mode or 'n'
        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
      end

      -- 重命名光标下的变量。
      --  大多数语言服务器都支持跨文件重命名等。
      map('grn', vim.lsp.buf.rename, '重命名')

      -- 执行代码操作，通常你的光标需要在错误上或者 LSP 给出的建议上才能激活这个操作。
      map('gra', vim.lsp.buf.code_action, '代码操作', { 'n', 'x' })

      -- 警告：这不是转到定义，这是转到声明。
      --  例如，在 C 语言中，这会带你到头文件。
      map('grD', vim.lsp.buf.declaration, '转到声明')

      -- 下面两个自动命令用于当你的光标在一个单词上停留一会儿时高亮这个单词的引用。
      --    查看 `:help CursorHold` 了解什么时候执行这个
      --
      -- 当你移动光标，高亮就会被清除（这是第二个自动命令做的）。
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if client and client:supports_method('textDocument/documentHighlight', event.buf) then
        local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.document_highlight,
        })

        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.clear_references,
        })

        vim.api.nvim_create_autocmd('LspDetach', {
          group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
          callback = function(event2)
            vim.lsp.buf.clear_references()
            vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
          end,
        })
      end

      -- 如果你的语言服务器支持内嵌提示，下面的代码创建了一个快捷键来切换代码中的内嵌提示
      --
      -- 这可能不是你想要的，因为它们会占用你一些代码空间
      if client and client:supports_method('textDocument/inlayHint', event.buf) then
        map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '切换内嵌提示')
      end
    end,
  })

  -- 启用以下语言服务器
  --  你可以在这里随意添加/删除任何你想要的 LSP。它们会被自动安装。
  --  查看 `:help lsp-config` 了解配置键和如何配置
  ---@type table<string, vim.lsp.Config>
  local servers = {
    -- clangd = {},
    -- gopls = {},
    -- pyright = {},
    -- tsc = {},
    --
    -- 有些语言（比如 rust）有完整的语言插件，很有用:
    --    https://github.com/mrcjkb/rustaceanvim
    --
    -- 但对于许多设置，LSP（`rust_analyzer`）就足够好用了
    -- rust_analyzer = {},

    stylua = {}, -- 用于格式化 Lua 代码

    -- 根据 neovim 帮助文档推荐的特殊 Lua 配置
    lua_ls = {
      on_init = function(client)
        client.server_capabilities.documentFormattingProvider = false -- 禁用格式化（格式化由 stylua 完成）

        if client.workspace_folders then
          local path = client.workspace_folders[1].name
          if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
        end

        local current_settings = client.config.settings --[[@as lspconfig.settings.lua_ls]]
        client.config.settings.Lua = vim.tbl_deep_extend('force', current_settings.Lua, {
          runtime = {
            version = 'LuaJIT',
            path = { 'lua/?.lua', 'lua/?/init.lua' },
          },
          workspace = {
            checkThirdParty = false,
            -- 注意：这会慢很多，在你处理自己的配置时会出问题。
            --  查看 https://github.com/neovim/nvim-lspconfig/issues/3189
            library = vim.api.nvim_get_runtime_file('', true),
          },
        })
      end,
      ---@type lspconfig.settings.lua_ls
      settings = {
        Lua = {
          format = { enable = false }, -- 禁用格式化（格式化由 stylua 完成）
        },
      },
    },
  }

  vim.pack.add {
    gh 'neovim/nvim-lspconfig',
    gh 'mason-org/mason.nvim',
    gh 'mason-org/mason-lspconfig.nvim',
    gh 'WhoIsSethDaniel/mason-tool-installer.nvim',
  }

  -- 自动安装 LSP 和相关工具到 Neovim 的 stdpath
  require('mason').setup {}

  -- 在 nvim-lspconfig 服务器名称和 mason.nvim 包名称之间转换（例如 lua_ls <-> lua-language-server）
  require('mason-lspconfig').setup {
    automatic_enable = false, -- 如果你想自动启用手动安装的服务器（比如通过 :Mason / :MasonInstall），请把这个改为 true
  }

  -- 确保上面的服务器和工具都已安装
  --
  -- 要检查已安装工具的当前状态和/或手动安装其他工具，你可以运行
  --    :Mason
  --
  -- 在这个菜单里你可以按 `g?` 获取帮助。
  local ensure_installed = vim.tbl_keys(servers or {})
  vim.list_extend(ensure_installed, {
    -- 你可以在这里添加其他你想让 Mason 安装的工具
  })

  require('mason-tool-installer').setup { ensure_installed = ensure_installed }

  for name, server in pairs(servers) do
    vim.lsp.config(name, server)
    vim.lsp.enable(name)
  end
end

-- ============================================================
-- 第七节：格式化
-- conform.nvim 配置和快捷键
-- ============================================================
do
  -- [[ 格式化 ]]
  vim.pack.add { gh 'stevearc/conform.nvim' }
  require('conform').setup {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- 你可以在这里指定保存时自动格式化的文件类型:
      local enabled_filetypes = {
        -- lua = true,
        -- python = true,
      }
      if enabled_filetypes[vim.bo[bufnr].filetype] then
        return { timeout_ms = 500 }
      else
        return nil
      end
    end,
    default_format_opts = {
      lsp_format = 'fallback', -- 如果下面配置了外部格式化器就使用，否则使用 LSP 格式化。设置为 `false` 完全禁用 LSP 格式化。
    },
    -- 你也可以在这里指定外部格式化器。
    formatters_by_ft = {
      -- rust = { 'rustfmt' },
      -- Conform 也可以按顺序运行多个格式化器
      -- python = { "isort", "black" },
      --
      -- 你可以使用 'stop_after_first' 只运行列表中第一个可用的格式化器
      -- javascript = { "prettierd", "prettier", stop_after_first = true },
    },
  }

  vim.keymap.set({ 'n', 'v' }, '<leader>f', function() require('conform').format { async = true } end, { desc = '格式化缓冲区' })
end

-- ============================================================
-- 第八节：自动补全与代码片段
-- blink.cmp 和 luasnip 配置
-- ============================================================
do
  -- [[ 代码片段引擎 ]]

  -- 注意：你也可以使用 git 标签来指定插件的版本范围。
  --  查看 `:help vim.version.range()` 获取更多信息
  vim.pack.add { { src = gh 'L3MON4D3/LuaSnip', version = vim.version.range '2.*' } }
  require('luasnip').setup {}

  -- `friendly-snippets` 包含各种预制代码片段。
  --    查看 README 了解各个语言/框架/插件片段:
  --    https://github.com/rafamadriz/friendly-snippets
  --
  -- vim.pack.add { gh 'rafamadriz/friendly-snippets' }
  -- require('luasnip.loaders.from_vscode').lazy_load()

  -- [[ 自动补全引擎 ]]
  vim.pack.add { { src = gh 'saghen/blink.cmp', version = vim.version.range '1.*' } }
  require('blink.cmp').setup {
    keymap = {
      -- 'default'（推荐）提供类似于内置补全的映射
      --   <c-y> 接受补全（[y]es）。
      --    如果你的 LSP 支持，这会自动导入。
      --    如果 LSP 提供了代码片段，这会展开片段。
      -- 'super-tab' 使用 tab 接受补全
      -- 'enter' 使用回车接受补全
      -- 'none' 不设置任何映射
      --
      -- 要理解为什么推荐 'default' 预设，你需要阅读 `:help ins-completion`
      --
      -- 不，说真的。请阅读 `:help ins-completion`，写得真的很好！
      --
      -- 所有预设都有以下映射:
      -- <tab>/<s-tab>: 在代码片段展开中向右/向左移动
      -- <c-space>: 打开菜单，如果已经打开就打开文档
      -- <c-n>/<c-p> 或 <up>/<down>: 选择下一个/上一个项目
      -- <c-e>: 隐藏菜单
      -- <c-k>: 切换签名帮助
      --
      -- 查看 `:help blink-cmp-config-keymap` 定义你自己的快捷键
      preset = 'default',

      -- 更高级的 Luasnip 快捷键（例如选择选择节点、展开）查看:
      --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
    },

    appearance = {
      -- 'mono'（默认）对应 'Nerd Font Mono' 或者 'normal' 对应 'Nerd Font'
      -- 调整间距确保图标对齐
      nerd_font_variant = 'mono',
    },

    completion = {
      -- 默认情况下，你可以按 `<c-space>` 显示文档。
      -- 你可以选择设置 `auto_show = true` 在延迟后自动显示文档。
      documentation = { auto_show = true, auto_show_delay_ms = 500 },
    },

    sources = {
      default = { 'lsp', 'path', 'snippets' },
    },

    snippets = { preset = 'luasnip' },

    -- Blink.cmp 包含一个可选的、推荐的 rust 模糊匹配器，
    -- 启用后会自动下载预编译二进制文件。
    --
    -- 默认情况下，我们改用 Lua 实现，但你可以通过 `'prefer_rust_with_warning'`
    -- 启用 rust 实现。
    --
    -- 查看 `:help blink-cmp-config-fuzzy` 获取更多信息
    fuzzy = { implementation = 'prefer_rust_with_warning' },

    -- 当你输入函数参数时显示签名帮助窗口
    signature = { enabled = true },
  }
end

-- ============================================================
-- 第九节：Treesitter
-- 语法分析器安装，语法高亮，折叠，缩进
-- ============================================================
do
  -- [[ 配置 Treesitter ]]
  --  用于高亮、编辑和导航代码
  --
  --  查看 `:help nvim-treesitter-intro`

  -- 注意：你也可以指定分支或特定提交
  vim.pack.add { { src = gh 'nvim-treesitter/nvim-treesitter', version = 'main' } }

  -- 确保基础语法分析器已安装
  local parsers = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' }
  require('nvim-treesitter').install(parsers)

  ---@param buf integer
  ---@param language string
  local function treesitter_try_attach(buf, language)
    -- 检查语法分析器是否存在并加载它
    if not vim.treesitter.language.add(language) then return end

    -- 检查缓冲区是否有效（安装完成后可能无效）
    if not vim.api.nvim_buf_is_valid(buf) then return end

    -- 启用语法高亮和其他 treesitter 功能
    vim.treesitter.start(buf, language)

    -- 启用 treesitter 折叠
    -- 更多关于折叠的信息查看 `:help folds`
    -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    -- vim.wo.foldmethod = 'expr'

    -- 检查这种语言是否支持 treesitter 缩进，如果支持就启用
    -- 如果没有缩进查询，缩进表达式会回退到 vim 内置的缩进表达式
    local has_indent_query = vim.treesitter.query.get(language, 'indents') ~= nil

    -- 启用 treesitter 缩进
    if has_indent_query then vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end
  end

  local available_parsers = require('nvim-treesitter').get_available()
  vim.api.nvim_create_autocmd('FileType', {
    callback = function(args)
      local buf, filetype = args.buf, args.match

      local language = vim.treesitter.language.get_lang(filetype)
      if not language then return end

      local installed_parsers = require('nvim-treesitter').get_installed 'parsers'

      if vim.tbl_contains(installed_parsers, language) then
        -- 如果已经安装了语法分析器就启用它
        treesitter_try_attach(buf, language)
      elseif vim.tbl_contains(available_parsers, language) then
        -- 如果 `nvim-treesitter` 提供了这个语法分析器，自动安装它，安装完成后启用
        require('nvim-treesitter').install(language):await(function() treesitter_try_attach(buf, language) end)
      else
        -- 如果语法分析器存在但 `nvim-treesitter` 不提供，尝试启用 treesitter 功能
        treesitter_try_attach(buf, language)
      end
    end,
  })
end

-- ============================================================
-- SECTION 10: OPTIONAL EXAMPLES / NEXT STEPS
-- kickstart.plugins.* examples
-- ============================================================
do
  -- The following comments only work if you have downloaded the kickstart repo, not just copy pasted the
  -- init.lua. If you want these files, they are in the repository, so you can just download them and
  -- place them in the correct locations.

  -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
  --
  --  Here are some example plugins that I've included in the Kickstart repository.
  --  Uncomment any of the lines below to enable them (you will need to restart nvim).
  --
  -- require 'kickstart.plugins.debug'
  -- require 'kickstart.plugins.indent_line'
  -- require 'kickstart.plugins.lint'
  -- require 'kickstart.plugins.autopairs'
  require 'kickstart.plugins.neo-tree'

  -- NOTE: You can add your own plugins, configuration, etc. in `lua/custom/plugins/*.lua`.
  --
  -- For independent modules, uncomment the convenience loader:
  require 'custom.plugins'
  --
  -- `custom.plugins` automatically loads files from that directory, but their
  -- order is unspecified. If plugins depend on each other, keep them in the same
  -- file and put their `vim.pack.add()` and `setup()` calls in the required order.
  --
  -- If separate modules need a specific order, require them explicitly instead:
  -- require 'custom.plugins.colorscheme'
  -- require 'custom.plugins.ui'
  -- require 'custom.plugins.git'
end

-- 这行下面的叫做 `modeline`。查看 `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
