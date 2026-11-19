-- ============================================================
-- Neovim 配置入口
-- ============================================================
-- 本文件只做一件事：按固定顺序加载各个模块。
-- 内容已按类别拆分到下面两个目录（前缀数字对应拆分前的 init.lua 节号）：
--
--   lua/custom/config/   核心设置
--     第一节 options.lua     选项、leader 键
--     第二节 keymaps.lua     基础快捷键
--     第二节 autocmds.lua    基础自动命令
--     第三节 pack.lua        vim.pack 构建钩子 + 各模块共用的 gh 辅助函数
--
--   lua/custom/plugins/  插件配置
--     第四节 ui.lua          guess-indent / gitsigns / which-key / 配色 / todo-comments / mini
--     第五节 telescope.lua   Telescope 与 LSP 选择器
--     第六节 lsp.lua         LSP、fidget、mason
--     第七节 format.lua      conform.nvim
--     第八节 completion.lua  luasnip + blink.cmp
--     第九节 treesitter.lua  nvim-treesitter
--     无对应节 helix-keys.lua  Helix 键位方案（见 doc/helix-keys.md）
--
-- 注意：下面的 require 顺序就是加载顺序，不要随意调整：
--   · options 必须最先——leader 键要在任何插件之前设置
--   · pack 必须早于所有插件模块——它们都要用 gh 辅助函数
--   · telescope 必须早于 helix-keys——后者在加载时就要 require 'telescope.builtin'
--   · helix-keys 放最后——这样它能覆盖前面已经注册的映射
--
-- 另外：拆分后不再使用「遍历目录自动 require」。那样加载顺序不确定，
-- 会破坏上面这些依赖。要新增模块，直接在下面加一行 require。
-- ============================================================

-- 通过缓存编译后的 Lua 模块来加速启动
vim.loader.enable()

require 'custom.config.options'
require 'custom.config.keymaps'
require 'custom.config.autocmds'
require 'custom.config.pack'

require 'custom.plugins.ui'
require 'custom.plugins.telescope'
require 'custom.plugins.chezmoi'
require 'custom.plugins.lsp'
require 'custom.plugins.format'
require 'custom.plugins.completion'
require 'custom.plugins.treesitter'
require 'custom.plugins.helix-keys'

-- ============================================================
-- 第十节：kickstart 官方示例插件
-- 文件来自 kickstart 仓库的 lua/kickstart/plugins/，取消注释即可启用
-- （注意：debug.lua 使用 <leader>b，会和 Helix 的 space b「缓冲区选择」冲突）
-- ============================================================
-- require 'kickstart.plugins.debug'
-- require 'kickstart.plugins.indent_line'
-- require 'kickstart.plugins.lint'
-- require 'kickstart.plugins.autopairs'
require 'kickstart.plugins.neo-tree'

-- 这行下面的叫做 `modeline`。查看 `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
