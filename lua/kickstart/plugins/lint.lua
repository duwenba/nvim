-- 代码检查

vim.pack.add { 'https://github.com/mfussenegger/nvim-lint' }

local lint = require 'lint'
lint.linters_by_ft = {
  markdown = { 'markdownlint' }, -- 确保通过 mason / npm 安装 `markdownlint`
}

-- 为了允许其他插件向 require('lint').linters_by_ft 添加检查器，
-- 请像这样设置 linters_by_ft:
-- lint.linters_by_ft = lint.linters_by_ft or {}
-- lint.linters_by_ft['markdown'] = { 'markdownlint' }
--
-- 但是请注意，这样会启用一组默认检查器，
-- 除非这些工具都已安装，否则会报错：
-- {
--   clojure = { "clj-kondo" },
--   dockerfile = { "hadolint" },
--   inko = { "inko" },
--   janet = { "janet" },
--   json = { "jsonlint" },
--   markdown = { "vale" },
--   rst = { "vale" },
--   ruby = { "ruby" },
--   terraform = { "tflint" },
--   text = { "vale" }
-- }
--
-- 你可以通过将文件类型设置为 nil 来禁用默认检查器：
-- lint.linters_by_ft['clojure'] = nil
-- lint.linters_by_ft['dockerfile'] = nil
-- lint.linters_by_ft['inko'] = nil
-- lint.linters_by_ft['janet'] = nil
-- lint.linters_by_ft['json'] = nil
-- lint.linters_by_ft['markdown'] = nil
-- lint.linters_by_ft['rst'] = nil
-- lint.linters_by_ft['ruby'] = nil
-- lint.linters_by_ft['terraform'] = nil
-- lint.linters_by_ft['text'] = nil

-- 创建自动命令在指定事件上执行实际的检查
local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
  group = lint_augroup,
  callback = function()
    -- 只在可修改的缓冲区运行检查，避免多余的噪音，
    -- 尤其是在使用 Markdown 描述悬停符号的 LSP 弹窗中。
    if vim.bo.modifiable then lint.try_lint() end
  end,
})
