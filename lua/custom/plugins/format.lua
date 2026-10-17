-- ============================================================
-- 第七节：格式化
-- conform.nvim 配置和快捷键
-- ============================================================

local gh = require('custom.config.pack').gh

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

-- 格式化（Helix 键位：= 格式化当前选区。原 <leader>f 已让给 Helix 的 space f「文件选择」）
vim.keymap.set({ 'n', 'v' }, '<leader>=', function() require('conform').format { async = true } end, { desc = '格式化缓冲区' })
