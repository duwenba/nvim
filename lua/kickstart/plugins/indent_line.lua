-- 即使在空行上也添加缩进指南线

-- 启用 `lukas-reineke/indent-blankline.nvim`
-- 查看 `:help ibl`
vim.pack.add { 'https://github.com/lukas-reineke/indent-blankline.nvim' }
require('ibl').setup {}
