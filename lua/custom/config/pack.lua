-- ============================================================
-- 第三节：插件管理器介绍
-- vim.pack 介绍、构建钩子，以及各插件模块共用的 gh 辅助函数
-- ============================================================
-- [[ `vim.pack` 介绍 ]]
-- `vim.pack` 是 Neovim 内置的新插件管理器，
--  它提供了一个用于安装和管理插件的 Lua 接口。
--
--  查看 `:help vim.pack`、`:help vim.pack-examples`，
--  或者查看 vim.pack 和 mini.nvim 创建者的优秀博客文章：
--  https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack
--
--  要检查插件状态和待处理的更新，请运行
--    :lua vim.pack.update(nil, { offline = true })
--
--  要更新插件，请运行
--    :lua vim.pack.update()
--
--
-- 在配置的其余部分，会有如何使用 `vim.pack` 安装和配置插件的示例。
--
-- 在本节中，我们设置了一些自动命令，在某些插件安装或更新后运行构建步骤。

local function run_build(name, cmd, cwd)
  local result = vim.system(cmd, { cwd = cwd }):wait()
  if result.code ~= 0 then
    local stderr = result.stderr or ''
    local stdout = result.stdout or ''
    local output = stderr ~= '' and stderr or stdout
    if output == '' then output = '构建命令没有输出。' end
    vim.notify(('%s 构建失败：\n%s'):format(name, output), vim.log.levels.ERROR)
  end
end

-- 这个自动命令在插件安装或更新后运行，
--  如果需要，为该插件运行适当的构建命令。
--
-- 查看 `:help vim.pack-events`
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name = ev.data.spec.name
    local kind = ev.data.kind
    if kind ~= 'install' and kind ~= 'update' then return end

    if name == 'telescope-fzf-native.nvim' and vim.fn.executable 'make' == 1 then
      run_build(name, { 'make' }, ev.data.path)
      return
    end

    if name == 'LuaSnip' then
      if vim.fn.has 'win32' ~= 1 and vim.fn.executable 'make' == 1 then run_build(name, { 'make', 'install_jsregexp' }, ev.data.path) end
      return
    end

    if name == 'nvim-treesitter' then
      if not ev.data.active then vim.cmd.packadd 'nvim-treesitter' end
      vim.cmd 'TSUpdate'
      return
    end
  end,
})

local M = {}

--- 因为大多数插件都托管在 GitHub 上，所以你可以使用这个辅助函数来减少各插件模块中的重复代码。
---@param repo string
---@return string
function M.gh(repo) return 'https://github.com/' .. repo end

return M
