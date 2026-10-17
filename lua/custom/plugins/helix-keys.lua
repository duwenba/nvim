-- ============================================================
-- Helix 键位方案迁移 —— L1：前缀菜单层
-- ============================================================
-- 把 Helix 默认键位里的「前缀菜单层」搬到 Neovim：
--   g ...       Helix 的 goto mode（跳转模式）
--   <Space>...  Helix 的 space mode（菜单模式）；本配置的 leader 本来就是空格
--   ] / [ ...   Helix 的 unimpaired 跳转层
--
-- 有意「不迁移」的部分（完整三类标注见 doc/helix-keys.md）：
--   m 层（Helix 的匹配/环绕）——保留 mini.surround 的 sa / sr / sd
--   z / Z 视图层——与 nvim 的折叠键硬冲突，nvim 原生 zz / zt / zb 已覆盖
--   Ctrl-w 窗口层——本来就和 vim 高度一致
--   space G 调试子菜单——本轮不迁
--   Alt-* 系列——终端不可靠
--
-- 本文件由 init.lua 在最后 require（顺序见 init.lua 里的加载顺序说明），因此可以覆盖前面的映射。
-- 每条都标注了对应的 Helix 键位，方便和 Helix 对照。
-- ============================================================

local function map(mode, lhs, rhs, desc) vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true }) end

-- LSP 安全包装：没有 LSP 客户端时给提示，而不是静默失败
local function lsp(fn)
  return function()
    if #vim.lsp.get_clients { bufnr = 0 } > 0 then
      fn()
    else
      vim.notify('该缓冲区没有 LSP 客户端', vim.log.levels.WARN)
    end
  end
end

-- ============================================================
-- 一、g 跳转层（Helix 的 goto mode）
-- ============================================================
-- 无需映射（与 nvim 原生一致）: gg / g| / n| / gf / gj / gk
-- 未迁移: gr（nvim 0.11+ 的 gr* 前缀组已占用，引用仍用 grr）
--         gw（单词标签跳转，nvim 无对应实现）
--         gn / gp（会牺牲 cgn 批量改匹配；缓冲切换改用下面的 <leader>bn / <leader>bp）

map('n', 'ge', 'G', 'Helix ge：跳转到文件末尾')
map('n', 'gh', '0', 'Helix gh：跳转到行首')
map('n', 'gl', '$', 'Helix gl：跳转到行尾')
map('n', 'gs', '^', 'Helix gs：跳转到行首第一个非空白字符')
map('n', 'gt', 'zt', 'Helix gt：当前行移到屏幕顶部')
map('n', 'gc', 'zz', 'Helix gc：当前行居中（注意：nvim 的 gc 注释操作符因此不可用，改用 space c 或 Ctrl-c）')
map('n', 'gb', 'zb', 'Helix gb：当前行移到屏幕底部')
map('n', 'gd', lsp(vim.lsp.buf.definition), 'Helix gd：跳转到定义')
map('n', 'gD', lsp(vim.lsp.buf.declaration), 'Helix gD：跳转到声明')
map('n', 'gy', lsp(vim.lsp.buf.type_definition), 'Helix gy：跳转到类型定义')
map('n', 'gi', lsp(vim.lsp.buf.implementation), 'Helix gi：跳转到实现')
map('n', 'ga', function() pcall(vim.cmd, 'edit #') end, 'Helix ga：跳到上次访问的文件')
map('n', 'gm', function() pcall(vim.cmd, 'edit #') end, 'Helix gm：跳到上次修改的文件（nvim 只有单个「备用文件」，与 ga 等价）')
map('n', 'g.', 'g;', 'Helix g.：跳到上次修改处')

-- 被抢键位的补偿
map('n', '<leader>tt', '<Cmd>tabnext<CR>', '补偿 gt：下一个标签页')
map('n', '<leader>tT', '<Cmd>tabprevious<CR>', '补偿 gt：上一个标签页')
map('n', '<leader>bn', '<Cmd>bnext<CR>', '替代 gn：下一个缓冲区')
map('n', '<leader>bp', '<Cmd>bprevious<CR>', '替代 gp：上一个缓冲区')

-- ============================================================
-- 二、<Space> 菜单层（Helix 的 space mode）
-- ============================================================
local builtin = require 'telescope.builtin'

map('n', '<leader>f', builtin.find_files, 'Helix space f：文件选择（工作区）')
map('n', '<leader>F', function() builtin.find_files { cwd = vim.fn.getcwd() } end, 'Helix space F：文件选择（当前目录）')
map('n', '<leader>e', '<Cmd>Neotree toggle<CR>', 'Helix space e：文件树')
map('n', '<leader>.', '<Cmd>Neotree reveal<CR>', 'Helix space .：文件树（当前文件所在目录）')
map('n', '<leader>b', builtin.buffers, 'Helix space b：缓冲区选择')
map('n', '<leader>s', builtin.lsp_document_symbols, 'Helix space s：文档符号')
map('n', '<leader>S', builtin.lsp_dynamic_workspace_symbols, 'Helix space S：工作区符号')
-- 注意：telescope 的 diagnostics 默认查的是「整个工作区」（bufnr ~= 0 时会被置为 nil），
-- 所以「当前文件诊断」必须显式传 bufnr = 0。
map('n', '<leader>d', function() builtin.diagnostics { bufnr = 0 } end, 'Helix space d：当前文件诊断')
map('n', '<leader>D', function() builtin.diagnostics { bufnr = nil } end, 'Helix space D：工作区诊断')
map('n', '<leader>a', lsp(vim.lsp.buf.code_action), 'Helix space a：代码动作')
map('n', '<leader>r', lsp(vim.lsp.buf.rename), 'Helix space r：重命名符号')
map('n', '<leader>k', lsp(vim.lsp.buf.hover), 'Helix space k：悬停文档')

-- Helix space c / Ctrl-c：切换注释。
-- 因为上面的 gc 已经被「当前行居中」占用，而 nvim 的 gcc/gc 本身就是一层映射
-- （不是内置命令，`:normal! gcc` 绕不过去），所以这里直接调用它的实现 vim._comment。
local function toggle_comment(line1, line2)
  local ok, comment = pcall(require, 'vim._comment')
  if ok and comment.toggle_lines then
    comment.toggle_lines(line1, line2)
  else
    vim.notify('当前 Neovim 版本不支持注释 API，请临时用 gc 前先取消本文件里 gc 的映射', vim.log.levels.WARN)
  end
end

local function toggle_comment_line() toggle_comment(vim.fn.line '.', vim.fn.line '.') end

-- 注意：可视模式里 '< / '> 两个标记要等退出可视模式才会写入，
-- 所以这里用当前光标（.）和可视选区另一端（v）来取范围。
local function toggle_comment_selection()
  local a, b = vim.fn.line '.', vim.fn.line 'v'
  toggle_comment(math.min(a, b), math.max(a, b))
end

map('n', '<leader>c', toggle_comment_line, 'Helix space c：切换注释（当前行）')
map('x', '<leader>c', toggle_comment_selection, 'Helix space c：切换注释（选区）')
map('n', '<C-c>', toggle_comment_line, 'Helix C-c：切换注释（当前行）')
map('x', '<C-c>', toggle_comment_selection, 'Helix C-c：切换注释（选区）')

-- Helix 的系统剪贴板族。nvim 已设 clipboard=unnamedplus，普通 y/p 本来就走系统剪贴板，
-- 这几条只是为了让 Helix 的肌肉记忆也能用。
map({ 'n', 'x' }, '<leader>y', '"+y', 'Helix space y：复制到系统剪贴板')
map({ 'n', 'x' }, '<leader>Y', '"+y', 'Helix space Y：复制主选区到系统剪贴板')
map({ 'n', 'x' }, '<leader>p', '"+p', 'Helix space p：粘贴系统剪贴板')
map({ 'n', 'x' }, '<leader>P', '"+P', 'Helix space P：粘贴系统剪贴板（光标前）')
map('x', '<leader>R', '"+p', 'Helix space R：用系统剪贴板替换选区')

map('n', '<leader>w', '<C-w>', 'Helix space w：进入窗口模式（等价 nvim 的 Ctrl-w）')
map('n', "<leader>'", builtin.resume, 'Helix space 单引号：上次的选择器')
map('n', '<leader>/', builtin.live_grep, 'Helix space /：全局搜索')
map('n', '<leader>?', builtin.commands, 'Helix space ?：命令面板')

-- 未迁移的 space 项（Helix 有、nvim 侧缺实现，见 doc/helix-keys.md）：
--   space j 跳转列表选择器、space g 已修改文件选择器（缺插件）
--   space h 选符号引用（需自研，且与 <leader>h 的 Git 块组冲突）
--   space C 块注释（nvim 没有块注释/行注释的区分）

-- ============================================================
-- 三、] / [ unimpaired 跳转层
-- ============================================================
-- 无需映射：]d [d ]D [D 与 nvim 内置的默认诊断跳转一致（已实测确认）
-- 无需映射：]g [g ]G [G 与 gitsigns 的导航一起定义在 custom/plugins/ui.lua

map('n', ']p', '}', 'Helix ]p：下一个段落')
map('n', '[p', '{', 'Helix [p：上一个段落')
map('n', ']<Space>', 'o<Esc>', 'Helix ]空格：在下方新增一行')
map('n', '[<Space>', 'O<Esc>', 'Helix [空格：在上方新增一行')

-- 二期（需要基于 nvim-treesitter 写通用查询，未在本次实现）：
--   ]c [c 下一个/上一个注释、]f [f 函数、]t [t 类、]a [a 参数、
--   ]e [e 条目、]T [T 测试、]x [x HTML 元素
