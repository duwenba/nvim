-- ============================================================
-- 附加模块：chezmoi.nvim
-- 在 Neovim 内编辑 chezmoi 托管的点文件，保存即自动 `chezmoi apply`
-- 仓库：https://github.com/xvzc/chezmoi.nvim
-- ============================================================
--
-- 与命令行 `chezmoi edit` 的区别：本插件用 Neovim 内置的 `:edit`
-- 打开 chezmoi 源文件（例如 ~/.bashrc -> ~/.local/share/chezmoi/dot_bashrc），
-- 因此可以同时编辑并监视多个文件。
--
-- 提供的能力：
--   :ChezmoiEdit <target...> [--watch] [--force]  打开源文件，可保存即 apply
--   :ChezmoiList <chezmoi managed 参数>            列出托管文件
--   require('chezmoi.pick').telescope()           选择器里挑选托管文件
--   require('chezmoi.commands')                   底层命令封装（source_path/list/apply/status/edit/target_path）

local gh = require('custom.config.pack').gh

-- plenary.nvim 是 chezmoi.nvim 的硬依赖（telescope 那节已经装过，这里重复写无害）
vim.pack.add {
  gh 'nvim-lua/plenary.nvim',
  gh 'xvzc/chezmoi.nvim',
}

require('chezmoi').setup {
  edit = {
    -- 默认不自动 apply，按需在命令后加 --watch
    watch = false,
    force = false,
  },
  events = {
    on_open = { notification = { enable = true, msg = '已打开 chezmoi 托管文件' } },
    on_watch = { notification = { enable = true, msg = '保存后将自动 apply' } },
    on_apply = { notification = { enable = true, msg = 'chezmoi apply 成功' } },
  },
}

-- 让 telescope 扩展可用（选中后打开源文件；不自动 watch）
pcall(require('telescope').load_extension, 'chezmoi')

-- [[ 快捷键 ]]
-- <leader>zc 在 telescope 里挑选 chezmoi 托管文件并编辑
vim.keymap.set('n', '<leader>zc', function()
  require('chezmoi.pick').telescope()
end, { desc = '[C]hezm[o]i: 挑选托管文件' })

-- <leader>zw 对当前文件的 target 开启 watch（当前 buffer 需是 chezmoi 源文件）
vim.keymap.set('n', '<leader>zw', function()
  local name = vim.api.nvim_buf_get_name(0)
  local source_root = vim.fn.expand '~/.local/share/chezmoi'
  if vim.startswith(name, source_root) then
    require('chezmoi.commands.__edit').watch(0)
  else
    vim.notify('当前文件不在 chezmoi 源目录下，请先用 :ChezmoiEdit <target> 打开', vim.log.levels.WARN)
  end
end, { desc = '[C]hezm[o]i: 监视当前文件并自动 apply' })

-- <leader>zl 列出托管文件
vim.keymap.set('n', '<leader>zl', '<cmd>ChezmoiList --include files --exclude externals<cr>', { desc = '[C]hezm[o]i: 列出托管文件' })
