-- ============================================================
-- 第五节：搜索与导航
-- Telescope 配置，快捷键，LSP 选择器映射
-- ============================================================

local gh = require('custom.config.pack').gh

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
--
-- 注意：Helix 键位方案迁移后，这一组只留「Helix 里没有对应项」的残余选择器，
-- 所以从 <leader>s 挪到了 <leader>u（原 <leader>s 让位给 Helix 的 space s）。
-- 有 Helix 对应项的选择器全部在 lua/custom/plugins/helix-keys.lua 里。
local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>uh', builtin.help_tags, { desc = '搜索帮助' })
vim.keymap.set('n', '<leader>uk', builtin.keymaps, { desc = '搜索快捷键' })
vim.keymap.set('n', '<leader>us', builtin.builtin, { desc = '搜索选择 Telescope' })
vim.keymap.set({ 'n', 'v' }, '<leader>uw', builtin.grep_string, { desc = '搜索当前单词' })
vim.keymap.set('n', '<leader>u.', builtin.oldfiles, { desc = '搜索最近文件' })

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

-- 在当前缓冲区模糊搜索（Helix 没有对应项；原来的 <leader>/ 已让给 Helix 的 space /）
vim.keymap.set('n', '<leader>ub', function()
  -- 你可以给 Telescope 传递额外的配置来改变主题、布局等。
  builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '在当前缓冲区模糊搜索' })

-- 也可以传递额外的配置选项。
--  查看 `:help telescope.builtin.live_grep()` 获取特定键的信息
vim.keymap.set(
  'n',
  '<leader>u/',
  function()
    builtin.live_grep {
      grep_open_files = true,
      prompt_title = '在打开文件中实时 Grep',
    }
  end,
  { desc = '搜索打开的文件' }
)

-- 搜索 Neovim 配置文件的快捷键
vim.keymap.set('n', '<leader>un', function() builtin.find_files { cwd = vim.fn.stdpath 'config', follow = true } end, { desc = '搜索 [ N ] eovim 文件' })
