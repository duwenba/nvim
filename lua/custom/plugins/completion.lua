-- ============================================================
-- 第八节：自动补全与代码片段
-- blink.cmp 和 luasnip 配置
-- ============================================================

local gh = require('custom.config.pack').gh

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
