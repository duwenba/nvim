-- ============================================================
-- 第一节：选项配置
-- Neovim 核心设置，leader 键，各类选项
-- ============================================================
-- 通过缓存编译后的 Lua 模块来加速启动
vim.loader.enable()

-- 设置 <空格> 为 leader 键
-- 查看 `:help mapleader`
--  注意：必须在加载插件之前设置（否则会使用错误的 leader）
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- 如果你安装并在终端中选择了 Nerd Font，就设置为 true
vim.g.have_nerd_font = true

-- [[ 设置选项 ]]
--  查看 `:help vim.o`
-- 注意：你可以根据自己的喜好更改这些选项！
--  更多选项，请查看 `:help option-list`

-- 默认显示行号
vim.o.number = true
vim.o.relativenumber = true

-- 开启鼠标支持，比如调整分屏大小的时候会很有用！
vim.o.mouse = 'a'

-- 不显示模式信息，因为状态栏已经显示了
vim.o.showmode = false

-- 在操作系统和 Neovim 之间同步剪贴板。
--  在 `UiEnter` 之后再设置，因为它会增加启动时间。
--  如果你希望操作系统剪贴板保持独立，请删除此选项。
--  查看 `:help 'clipboard'`
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

-- 开启折行缩进
vim.o.breakindent = true

-- 即使关闭并重新打开文件，也支持撤销/重做修改
vim.o.undofile = true

-- 搜索不区分大小写，除非使用 \C 或搜索词中有一个或多个大写字母
vim.o.ignorecase = true
vim.o.smartcase = true

-- 默认保持显示签名列
vim.o.signcolumn = 'yes'

-- 减少更新时间
vim.o.updatetime = 250

-- 减少映射序列等待时间
vim.o.timeoutlen = 300

-- 配置新分屏的打开方式
vim.o.splitright = true
vim.o.splitbelow = true

-- 设置 neovim 如何在编辑器中显示某些空白字符。
--  查看 `:help 'list'`
--  和 `:help 'listchars'`
--
--  注意 listchars 是使用 `vim.opt` 而不是 `vim.o` 设置的。
--  它和 `vim.o` 非常相似，但提供了一个方便操作表的接口。
--   查看 `:help lua-options`
--   和 `:help lua-guide-options`
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- 实时预览替换，边输入边预览！
vim.o.inccommand = 'split'

-- 显示光标所在行
vim.o.cursorline = true

-- 光标上下保持最少的屏幕行数。
vim.o.scrolloff = 10

-- 如果因为缓冲区有未保存的更改导致操作失败（比如 `:q`），
-- 弹出对话框询问你是否要保存当前文件
-- 查看 `:help 'confirm'`
vim.o.confirm = true
