-- debug.lua
--
-- 展示如何使用 DAP 插件调试代码。
--
-- 主要专注于配置 Go 的调试器，但也可以扩展到其他语言。
-- 这就是为什么它叫做 kickstart.nvim 而不是 kitchen-sink.nvim ;)

vim.pack.add {
  'https://github.com/mfussenegger/nvim-dap',
  'https://github.com/rcarriga/nvim-dap-ui',
  'https://github.com/nvim-neotest/nvim-nio',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/jay-babu/mason-nvim-dap.nvim',
  'https://github.com/leoluz/nvim-dap-go',
}

-- 基础调试快捷键，随意改成你喜欢的！
vim.keymap.set('n', '<F5>', function() require('dap').continue() end, { desc = '调试: 开始/继续' })
vim.keymap.set('n', '<F1>', function() require('dap').step_into() end, { desc = '调试: 步入' })
vim.keymap.set('n', '<F2>', function() require('dap').step_over() end, { desc = '调试: 步过' })
vim.keymap.set('n', '<F3>', function() require('dap').step_out() end, { desc = '调试: 步出' })
vim.keymap.set('n', '<leader>b', function() require('dap').toggle_breakpoint() end, { desc = '调试: 切换断点' })
vim.keymap.set('n', '<leader>B', function() require('dap').set_breakpoint(vim.fn.input '断点条件: ') end, { desc = '调试: 设置条件断点' })
-- 切换查看上次会话结果。不这样做，遇到未处理异常时你看不到会话输出。
vim.keymap.set('n', '<F7>', function() require('dapui').toggle() end, { desc = '调试: 查看上次会话结果。' })

local dap = require 'dap'
local dapui = require 'dapui'

require('mason-nvim-dap').setup {
  -- 尽最大努力用合理的调试配置设置各种调试器
  automatic_installation = true,

  -- 你可以为处理器提供额外配置，查看 mason-nvim-dap README 获取更多信息
  handlers = {},

  -- 你需要在线检查你已经安装了所需的东西，所以不用问我怎么安装它们:)
  ensure_installed = {
    -- 更新这里确保你有所需语言的调试器
    'delve',
  },
}

-- Dap UI 配置
-- 更多信息，查看 |:help nvim-dap-ui|
---@diagnostic disable-next-line: missing-fields
dapui.setup {
  -- 将图标设置为更可能在所有终端中正常工作的字符。
  --    随意删除或使用你更喜欢的图标 :)
  --    不要觉得这些是好选择。
  icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
  ---@diagnostic disable-next-line: missing-fields
  controls = {
    icons = {
      pause = '⏸',
      play = '▶',
      step_into = '⏎',
      step_over = '⏭',
      step_out = '⏮',
      step_back = 'b',
      run_last = '▶▶',
      terminate = '⏹',
      disconnect = '⏏',
    },
  },
}

-- 修改断点图标
-- vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
-- vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
-- local breakpoint_icons = vim.g.have_nerd_font
--     and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
--   or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
-- for type, icon in pairs(breakpoint_icons) do
--   local tp = 'Dap' .. type
--   local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
--   vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
-- end

dap.listeners.after.event_initialized['dapui_config'] = dapui.open
dap.listeners.before.event_terminated['dapui_config'] = dapui.close
dap.listeners.before.event_exited['dapui_config'] = dapui.close

-- 安装 golang 特定配置
require('dap-go').setup {
  delve = {
    -- 在 Windows 上 delve 必须附加模式运行，否则会崩溃。
    -- 查看 https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
    detached = vim.fn.has 'win32' == 0,
  },
}
