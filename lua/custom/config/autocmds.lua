-- ============================================================
-- 第二节：自动命令（快捷键见同目录的 keymaps.lua）
-- 基础 autocmd：复制文本时高亮
-- ============================================================

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
