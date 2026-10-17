-- ============================================================
-- 第九节：Treesitter
-- 语法分析器安装，语法高亮，折叠，缩进
-- ============================================================

local gh = require('custom.config.pack').gh

-- [[ 配置 Treesitter ]]
--  用于高亮、编辑和导航代码
--
--  查看 `:help nvim-treesitter-intro`

-- 注意：你也可以指定分支或特定提交
vim.pack.add { { src = gh 'nvim-treesitter/nvim-treesitter', version = 'main' } }

-- 确保基础语法分析器已安装
local parsers = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' }
require('nvim-treesitter').install(parsers)

---@param buf integer
---@param language string
local function treesitter_try_attach(buf, language)
  -- 检查语法分析器是否存在并加载它
  if not vim.treesitter.language.add(language) then return end

  -- 检查缓冲区是否有效（安装完成后可能无效）
  if not vim.api.nvim_buf_is_valid(buf) then return end

  -- 启用语法高亮和其他 treesitter 功能
  vim.treesitter.start(buf, language)

  -- 启用 treesitter 折叠
  -- 更多关于折叠的信息查看 `:help folds`
  -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
  -- vim.wo.foldmethod = 'expr'

  -- 检查这种语言是否支持 treesitter 缩进，如果支持就启用
  -- 如果没有缩进查询，缩进表达式会回退到 vim 内置的缩进表达式
  local has_indent_query = vim.treesitter.query.get(language, 'indents') ~= nil

  -- 启用 treesitter 缩进
  if has_indent_query then vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end
end

local available_parsers = require('nvim-treesitter').get_available()
vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    local buf, filetype = args.buf, args.match

    local language = vim.treesitter.language.get_lang(filetype)
    if not language then return end

    local installed_parsers = require('nvim-treesitter').get_installed 'parsers'

    if vim.tbl_contains(installed_parsers, language) then
      -- 如果已经安装了语法分析器就启用它
      treesitter_try_attach(buf, language)
    elseif vim.tbl_contains(available_parsers, language) then
      -- 如果 `nvim-treesitter` 提供了这个语法分析器，自动安装它，安装完成后启用
      require('nvim-treesitter').install(language):await(function() treesitter_try_attach(buf, language) end)
    else
      -- 如果语法分析器存在但 `nvim-treesitter` 不提供，尝试启用 treesitter 功能
      treesitter_try_attach(buf, language)
    end
  end,
})
