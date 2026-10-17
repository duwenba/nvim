-- ============================================================
-- 第二节：快捷键（自动命令见同目录的 autocmds.lua）
-- 基础键位：清除搜索高亮、诊断、终端、窗口导航
-- ============================================================
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
