-- ============================================================
-- 第四节：UI / 核心用户体验插件
-- guess-indent, gitsigns, which-key, colorscheme, todo-comments, mini 模块
-- ============================================================

local gh = require('custom.config.pack').gh

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
    -- 导航（Helix 键位：]g / [g。原来的 ]c / [c 让给了 Helix 的「上/下一个注释」，
    -- 那一条属于二期（需要 treesitter），见 doc/helix-keys.md）
    vim.keymap.set('n', ']g', function()
      if vim.wo.diff then
        vim.cmd.normal { ']c', bang = true }
      else
        gitsigns.nav_hunk 'next'
      end
    end, { desc = '下一个 git 变更', buf = bufnr })

    vim.keymap.set('n', '[g', function()
      if vim.wo.diff then
        vim.cmd.normal { '[c', bang = true }
      else
        gitsigns.nav_hunk 'prev'
      end
    end, { desc = '上一个 git 变更', buf = bufnr })

    vim.keymap.set('n', ']G', function() gitsigns.nav_hunk 'last' end, { desc = '最后一个 git 变更', buf = bufnr })
    vim.keymap.set('n', '[G', function() gitsigns.nav_hunk 'first' end, { desc = '第一个 git 变更', buf = bufnr })

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
    -- 注意：<leader>s 已让给 Helix 的 space s（文档符号选择），
    -- 残余的搜索选择器搬到了 <leader>u，见第五节。
    { '<leader>u', group = '搜索（其它）', mode = { 'n', 'v' } },
    { '<leader>t', group = '切换' },
    { '<leader>h', group = 'Git 块', mode = { 'n', 'v' } }, -- 先启用 gitsigns 推荐快捷键
    { 'gr', group = 'LSP 操作', mode = { 'n' } },
    -- Helix 键位方案新增的前缀分组
    { 'g', group = '跳转（Helix goto）', mode = { 'n' } },
    { ']', group = '下一个', mode = { 'n' } },
    { '[', group = '上一个', mode = { 'n' } },
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
