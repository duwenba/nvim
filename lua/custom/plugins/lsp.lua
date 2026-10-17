-- ============================================================
-- 第六节：LSP
-- LSP 快捷键，服务端配置，Mason 工具安装
-- ============================================================

local gh = require('custom.config.pack').gh

-- [[ LSP 配置 ]]
-- 简短题外话：**什么是 LSP？**
--
-- LSP 是你可能听过的首字母缩写，但可能不知道它是什么。
--
-- LSP 代表语言服务器协议（Language Server Protocol）。它是一个帮助编辑器
-- 和语言工具以标准化方式通信的协议。
--
-- 一般来说，你有一个"服务器"，它是一个理解特定语言的工具（比如 `gopls`、`lua_ls`、`rust_analyzer` 等）。
-- 这些语言服务器（有时叫 LSP 服务器，就像 ATM 机一样，多说一次）是独立进程，
-- 和"客户端"通信 - 在这个情况下客户端就是 Neovim！
--
-- LSP 为 Neovim 提供了以下功能:
--  - 转到定义
--  - 查找引用
--  - 自动补全
--  - 符号搜索
--  - 还有更多！
--
-- 因此，语言服务器是必须与 Neovim 分开安装的外部工具。这就是 `mason`
-- 和相关插件发挥作用的地方。
--
-- 如果你想知道 lsp 和 treesitter 的区别，你可以查看精彩简洁的帮助文档 `:help lsp-vs-treesitter`

-- 为 LSP 提供有用的状态更新。
vim.pack.add { gh 'j-hui/fidget.nvim' }
require('fidget').setup {}

--  当 LSP 附加到特定缓冲区时运行这个函数。
--    也就是说，每次打开一个与 lsp 关联的新文件（例如，打开 `main.rs` 会关联 `rust_analyzer`），
--    这个函数就会被执行，配置当前缓冲区
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    -- 注意：记住 Lua 是一个真正的编程语言，因此可以定义小的辅助工具函数，这样你就不必重复自己。
    --
    -- 在这种情况下，我们创建了一个函数，让我们可以更轻松地定义特定于 LSP 相关项目的映射。
    -- 它每次都会为我们设置模式、缓冲区和描述。
    local map = function(keys, func, desc, mode)
      mode = mode or 'n'
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    -- 重命名光标下的变量。
    --  大多数语言服务器都支持跨文件重命名等。
    map('grn', vim.lsp.buf.rename, '重命名')

    -- 执行代码操作，通常你的光标需要在错误上或者 LSP 给出的建议上才能激活这个操作。
    map('gra', vim.lsp.buf.code_action, '代码操作', { 'n', 'x' })

    -- 警告：这不是转到定义，这是转到声明。
    --  例如，在 C 语言中，这会带你到头文件。
    map('grD', vim.lsp.buf.declaration, '转到声明')

    -- 下面两个自动命令用于当你的光标在一个单词上停留一会儿时高亮这个单词的引用。
    --    查看 `:help CursorHold` 了解什么时候执行这个
    --
    -- 当你移动光标，高亮就会被清除（这是第二个自动命令做的）。
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method('textDocument/documentHighlight', event.buf) then
      local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })

      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
        end,
      })
    end

    -- 如果你的语言服务器支持内嵌提示，下面的代码创建了一个快捷键来切换代码中的内嵌提示
    --
    -- 这可能不是你想要的，因为它们会占用你一些代码空间
    if client and client:supports_method('textDocument/inlayHint', event.buf) then
      map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '切换内嵌提示')
    end
  end,
})

-- 启用以下语言服务器
--  你可以在这里随意添加/删除任何你想要的 LSP。它们会被自动安装。
--  查看 `:help lsp-config` 了解配置键和如何配置
---@type table<string, vim.lsp.Config>
local servers = {
  -- clangd = {},
  -- gopls = {},
  -- pyright = {},
  -- tsc = {},
  --
  -- 有些语言（比如 rust）有完整的语言插件，很有用:
  --    https://github.com/mrcjkb/rustaceanvim
  --
  -- 但对于许多设置，LSP（`rust_analyzer`）就足够好用了
  -- rust_analyzer = {},

  stylua = {}, -- 用于格式化 Lua 代码

  -- 根据 neovim 帮助文档推荐的特殊 Lua 配置
  lua_ls = {
    on_init = function(client)
      client.server_capabilities.documentFormattingProvider = false -- 禁用格式化（格式化由 stylua 完成）

      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
      end

      local current_settings = client.config.settings --[[@as lspconfig.settings.lua_ls]]
      client.config.settings.Lua = vim.tbl_deep_extend('force', current_settings.Lua, {
        runtime = {
          version = 'LuaJIT',
          path = { 'lua/?.lua', 'lua/?/init.lua' },
        },
        workspace = {
          checkThirdParty = false,
          -- 注意：这会慢很多，在你处理自己的配置时会出问题。
          --  查看 https://github.com/neovim/nvim-lspconfig/issues/3189
          library = vim.api.nvim_get_runtime_file('', true),
        },
      })
    end,
    ---@type lspconfig.settings.lua_ls
    settings = {
      Lua = {
        format = { enable = false }, -- 禁用格式化（格式化由 stylua 完成）
      },
    },
  },
}

vim.pack.add {
  gh 'neovim/nvim-lspconfig',
  gh 'mason-org/mason.nvim',
  gh 'mason-org/mason-lspconfig.nvim',
  gh 'WhoIsSethDaniel/mason-tool-installer.nvim',
}

-- 自动安装 LSP 和相关工具到 Neovim 的 stdpath
require('mason').setup {}

-- 在 nvim-lspconfig 服务器名称和 mason.nvim 包名称之间转换（例如 lua_ls <-> lua-language-server）
require('mason-lspconfig').setup {
  automatic_enable = false, -- 如果你想自动启用手动安装的服务器（比如通过 :Mason / :MasonInstall），请把这个改为 true
}

-- 确保上面的服务器和工具都已安装
--
-- 要检查已安装工具的当前状态和/或手动安装其他工具，你可以运行
--    :Mason
--
-- 在这个菜单里你可以按 `g?` 获取帮助。
local ensure_installed = vim.tbl_keys(servers or {})
vim.list_extend(ensure_installed, {
  -- 你可以在这里添加其他你想让 Mason 安装的工具
})

require('mason-tool-installer').setup { ensure_installed = ensure_installed }

for name, server in pairs(servers) do
  vim.lsp.config(name, server)
  vim.lsp.enable(name)
end
