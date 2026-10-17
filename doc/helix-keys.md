# Helix → Neovim 键位迁移对照表

本文件记录「把 Helix 的键位方案迁移到 Neovim」这一次改动的**全部决策与取舍**，
以后忘了为什么某个键是现在这样，先看这里。

- **迁移范围**：只做 L1「前缀菜单层」——Helix 的 `g` 跳转模式、`Space` 菜单模式、`]` / `[` unimpaired 层。
- **不做**：L2 语义改造（`w` / `d` / `x` / `s` / `%` 在 Helix 里是「选中」不是「移动/操作」）与 L3 操作模型
  （selection-first、内置多光标）。那两层的成本远高于收益，已明确排除。
- **Helix 键位来源**：上游源码 `helix-term/src/keymap/default.rs` 与官方文档源 `book/src/keymap.md`
  （注意：官方渲染页 docs.helix-editor.com 与源码有 6 处出入，本表以源码为准）。
- **Neovim 实测环境**：v0.12.6。
- **本机 Helix 版本未知**：`hx` 不在 PATH，无法核对。若你的 Helix 版本较旧，
  `space k` / `space h` / `space D` / `gw` / `space G` 调试子菜单等较新的键位可能不存在于你那台 Helix 里
  （这只影响对照，不影响 Neovim 侧的行为）。

对应实现在 `lua/custom/plugins/helix-keys.lua`（自包含）；
另外几处分散在插件模块里：gitsigns 的 git 跳转键与 which-key 分组在 `lua/custom/plugins/ui.lua`，
Telescope 残余选择器在 `lua/custom/plugins/telescope.lua`，格式化快捷键在 `lua/custom/plugins/format.lua`。

---

## 一、本次新增的 Helix 键位

### 1.1 `g` 跳转层（Helix 的 goto mode）

| Helix 键 | Helix 语义 | 本配置映射到 | 备注 |
| --- | --- | --- | --- |
| `ge` | 文件末尾 | `G` | 覆盖 vim 的 `ge`（上一词尾），补偿见第五节 |
| `gh` | 行首 | `0` | 覆盖 vim 的 `gh`（字符级 Select 模式） |
| `gl` | 行尾 | `$` | 原生空闲 |
| `gs` | 行首第一个非空白字符 | `^` | 原生空闲 |
| `gt` | 当前行移到屏幕顶部 | `zt` | 覆盖 vim 的 `gt`（下一个标签页），补偿见第五节 |
| `gc` | 当前行居中 | `zz` | 覆盖 vim 的注释操作符 `gc`，补偿见第五节 |
| `gb` | 当前行移到屏幕底部 | `zb` | 原生空闲 |
| `gd` | 跳转到定义 | LSP `definition` | 覆盖 vim 的 `gd`（局部声明），语义更贴合 Helix |
| `gD` | 跳转到声明 | LSP `declaration` | 同上 |
| `gy` | 跳转到类型定义 | LSP `type_definition` | 原生空闲 |
| `gi` | 跳转到实现 | LSP `implementation` | 覆盖 vim 的 `gi`（跳回上次插入处） |
| `ga` | 上次访问的文件 | `:edit #` | 覆盖 vim 的 `ga`（字符编码信息） |
| `gm` | 上次修改的文件 | `:edit #` | vim 只有单个「备用文件」概念，与 `ga` 等价，属近似实现 |
| `g.` | 上次修改处 | `g;` | 原生空闲 |

### 1.2 `Space` 菜单层（Helix 的 space mode；本配置的 leader 就是空格）

| Helix 键 | Helix 语义 | 本配置映射到 |
| --- | --- | --- |
| `space f` | 文件选择（工作区） | Telescope `find_files` |
| `space F` | 文件选择（当前目录） | Telescope `find_files`（cwd） |
| `space e` | 文件树 | `:Neotree toggle` |
| `space .` | 文件树（当前文件目录） | `:Neotree reveal` |
| `space b` | 缓冲区选择 | Telescope `buffers` |
| `space s` | 文档符号 | Telescope `lsp_document_symbols` |
| `space S` | 工作区符号 | Telescope `lsp_dynamic_workspace_symbols` |
| `space d` | 当前文件诊断 | Telescope `diagnostics { bufnr = 0 }` |
| `space D` | 工作区诊断 | Telescope `diagnostics { bufnr = nil }` |
| `space a` | 代码动作 | LSP `code_action` |
| `space r` | 重命名符号 | LSP `rename` |
| `space k` | 悬停文档 | LSP `hover` |
| `space c` | 切换注释 | `vim._comment.toggle_lines`（行 / 选区） |
| `Ctrl-c` | 切换注释（Helix 原生同款） | 同上 |
| `space y` / `Y` | 复制到系统剪贴板 | `"+y` |
| `space p` / `P` | 从系统剪贴板粘贴 | `"+p` / `"+P` |
| `space R` | 用剪贴板内容替换选区 | `"+p`（可视模式） |
| `space w` | 进入窗口模式 | `<C-w>`（直接复用 nvim 整个窗口层） |
| `space '` | 上次的选择器 | Telescope `resume` |
| `space /` | 全局搜索 | Telescope `live_grep` |
| `space ?` | 命令面板 | Telescope `commands` |

> 说明：`space p/P/y/Y/R` 在 Helix 里必须显式按键，是因为 Helix 默认不写系统剪贴板。
> 本配置已设 `clipboard=unnamedplus`，普通 `y` / `p` 本来就走系统剪贴板；
> 这几条只是为了保留 Helix 的肌肉记忆，属于冗余但无害的映射。

### 1.3 `]` / `[` unimpaired 层

| Helix 键 | Helix 语义 | 本配置映射到 |
| --- | --- | --- |
| `]d` / `[d` / `]D` / `[D` | 上/下/首/末个诊断 | **已对齐，nvim 0.12 内置默认映射，无需动作** |
| `]g` / `[g` | 上/下个 git 变更 | gitsigns `nav_hunk`（定义在 `lua/custom/plugins/ui.lua`） |
| `]G` / `[G` | 末/首个 git 变更 | gitsigns `nav_hunk` |
| `]p` / `[p` | 上/下个段落 | `}` / `{` |
| `]space` / `[space` | 下/上加一个空行 | `o<Esc>` / `O<Esc>` |

---

## 二、已对齐、无需任何动作

| Helix 键 | 说明 |
| --- | --- |
| `gg`、`nG` | 文件头、跳到第 n 行 |
| `g\|`、`n\|` | 跳到第 1 / 第 n 列 |
| `gf` | 打开光标下的文件 |
| `gj` / `gk` | 屏幕行上下移动 |
| `Tab` | Helix 的 `Tab` = `jump_forward`，与 vim 的 `<C-i>` / `Tab` 一致 |
| `Ctrl-w` 窗口层 | 与 vim 高度一致（差异只有 `C-w t`，见第四节） |
| 方向键、`Home` / `End`、翻页键 | 含义一致 |
| `]d` / `[d` / `]D` / `[D` | 诊断跳转（nvim 0.12 内置默认） |

> 意外收获：nvim 原生就带了一批「unimpaired 风格」的 `]` / `[` 键，和 Helix 这一层的精神一致——
> `]b` / `[b` 缓冲区、`]q` / `[q` quickfix、`]l` / `[l` 位置列表、`]t` / `]T` 标签页、`]a` / `[a` 参数列表、`]f`?（无）。
> 实测确认这些**都存在但语义与 Helix 不同**（Helix 的 `]t` 是「下一个类」、`]a` 是「下一个参数」），
> 见第六节的二期冲突说明。

---

## 三、有意「不迁移」（保留 vim/本配置的现有行为）

| Helix 键位 | Helix 语义 | 不迁的理由 |
| --- | --- | --- |
| `m` 层全部 | `mm` 匹配括号、`ms`/`mr`/`md` 环绕、`ma`/`mi` 文本对象 | 全部与 vim 的「设置标记」撞位；本配置已装 mini.surround（`sa`/`sr`/`sd`）与 mini.ai，功能已覆盖，不值得牺牲标记位 |
| `gn` / `gp` | 上/下一个缓冲区 | 会牺牲 vim 的 `gn`（选中下一个搜索匹配，`cgn` 批量改匹配的基石）。缓冲切换改用 `<leader>bn` / `<leader>bp`。**这是唯一一条「损失大于收益」的项，若要恢复 Helix 行为，删掉 helix-keys.lua 里那两行并加 `gn`/`gp` 映射即可** |
| `gr` | 跳转引用 | nvim 0.11+ 的 `gr*` 前缀组已占用；引用用 `grr` |
| `gw` | 单词标签跳转 | nvim 无对应实现（需 hop.nvim 之类插件） |
| `z` / `Z` 视图层 | 屏幕对齐、滚动 | `zc`（居中）与 vim 的折叠键 `zc` 硬冲突，而 nvim 原生已有 `zz` / `zt` / `zb` |
| `Ctrl-w t` | 交换相邻分屏 | vim 的 `C-w t` 是「最顶部窗口」，两者都少用，不折腾 |
| `space j` | 跳转列表选择器 | 缺插件 |
| `space g` | 已修改文件选择器 | 缺插件 |
| `space h` | 选符号引用 | 需自研，且与本配置的 `<leader>h`（Git 块组）冲突 |
| `space C` | 块注释 | nvim 不区分「块注释 / 行注释」 |
| `space G` 调试子菜单 | DAP 一族（15 个键位） | 本轮明确不做。注意：将来若启用 `lua/kickstart/plugins/debug.lua`，那里用的是 `space b` / `space B`，会与 `space b`（缓冲区选择）冲突，需要先挪开 |
| `Alt-*` 系列 | 选区扩展、树节点选择等 30+ 个 | 终端能否传入本就不可靠 |

---

## 四、被「抢走」的 vim 键位与补偿

这是本次改动**唯一需要你重新建立肌肉记忆**的部分：

| 被抢的键 | 原来的 vim 行为 | 现在的行为 | 补偿方式 |
| --- | --- | --- | --- |
| `ge` | 上一个词尾 | 文件末尾 | `gE`（WORD 版，保留） |
| `gh` | 字符级 Select 模式 | 行首 | `gH`（行级 Select，保留） |
| `gt` | 下一个标签页 | 屏幕顶部 | **`<leader>tt` / `<leader>tT`** |
| `gc` | 注释操作符（`gcc`、`gc` + motion） | 当前行居中 | **`space c` / `Ctrl-c`**（Helix 原生同款注释键） |
| `gi` | 跳回上次插入处并进入插入 | 跳转实现 | `` `. ``（跳到最后修改处） |
| `ga` | 字符编码信息 | 上次访问的文件 | `:ascii` |
| `gm` | 屏幕行中点 | 上次修改的文件 | 无（价值低，可接受） |
| `gd` / `gD` | 局部声明 / 本文件声明 | LSP 定义 / 声明 | 无（本来也更常用 LSP 语义） |
| `]c` / `[c` | 你原先的「上/下个 git 变更」 | 空（二期留给「上/下个注释」） | git 跳转改走 **`]g` / `[g`** |

---

## 五、`<leader>` 层面的重新排布

| 原来的键 | 现在 | 原因 |
| --- | --- | --- |
| `<leader>f` 格式化 | **`<leader>=`** | Helix 用 `=` 格式化；`<leader>f` 让给 Helix 的 `space f`（文件选择） |
| `<leader>sf` 搜索文件 | `space f` | Helix 优先 |
| `<leader>sg` 实时 Grep | `space /` | 同上 |
| `<leader>sd` 搜索诊断 | `space d`（当前文件）/ `space D`（工作区） | 同上，且顺带修正了原来「当前文件」其实是全工作区的语义 |
| `<leader>sr` 恢复搜索 | `space '` | 同上 |
| `<leader>sc` 搜索命令 | `space ?` | 同上 |
| `<leader><leader>` 缓冲区列表 | `space b` | 同上 |
| `<leader>/` 当前缓冲模糊查找 | **`<leader>ub`** | `space /` 让给 Helix 的全局搜索 |
| `<leader>sh/sk/ss/sw/s./sn/s/` | **`<leader>uh/uk/us/uw/u./un/u/`** | 这些在 Helix 里没有对应项；`<leader>s` 必须整体让位给 Helix 的 `space s`（否则按键会等待 timeoutlen，破坏零延迟） |
| `<leader>q`、`<leader>t*`、`<leader>h*`、`gr*` | 不变 | 与 Helix 键位不冲突 |

---

## 六、二期（本次未实现）

全部依赖 **nvim-treesitter 通用查询**，且效果取决于各语言的 parser 质量，所以单独做、单独验：

- `]c` / `[c` 上/下个注释（因此这两个键目前是空的；它们已实测确认为空闲）
- `]f` / `[f` 函数、`]e` / `[e` 条目、`]x` / `[x` HTML 元素、`]T` / `[T` 测试（实测均空闲）
- ⚠️ `]t` / `[t` 类（Helix）**与 nvim 原生的 `:tnext` / `:tprevious`（标签页）冲突**
- ⚠️ `]a` / `[a` 参数（Helix）**与 nvim 原生的 `:next` / `:previous`（参数列表）冲突**

上面两条冲突是实测发现的原计划疏漏：二期要做得先决定「挪走 nvim 原生映射」还是「放弃这两项」。

其中 `]T` / `]e` / `]x` 可能只对部分语言有效。

---

## 七、验收清单

- [ ] `nvim` 冷启动无报错
- [ ] `gt` / `gc` 的补偿可用：`<leader>tt`/`<leader>tT` 切标签页、`space c` 与 `Ctrl-c` 切注释（普通模式 + 可视模式都验）
- [ ] `space s` **零延迟**（原 `<leader>s*` 已全部搬走，不残留）
- [ ] `space d` 是当前文件诊断、`space D` 是全工作区诊断
- [ ] `cgn` 仍可用（证明 `gn` 未被抢）
- [ ] 在有改动的 git 仓库里 `]g` / `[g` / `]G` / `[G` 能跳 git 块
- [ ] `gc` 变成居中（预期行为，不再是注释）
- [ ] `which-key` 里 `g`、`]`、`[`、`<leader>u` 显示分组名
- [ ] `:Map` / `:verbose map` 抽查几条，desc 里带 `Helix` 前缀，便于识别来源

---

## 八、已知风险

1. **`vim._comment` 是 Neovim 内部 API**。因为 `gc` 被「当前行居中」占用，而 nvim 的 `gcc`/`gc` 本身是一层映射
   （不是内置命令，`:normal! gcc` 绕不过去），所以注释只能直接调用它的实现。
   文件里已用 `pcall` 兜底：API 变动时会提示，而不是静默失效。这是本次改动里**唯一有版本升级风险**的地方。
2. **`space p/P/y/Y/R` 与 `clipboard=unnamedplus` 功能重叠**，属于冗余映射，删掉不影响任何功能。
3. **`ga` / `gm` 都是近似实现**：neovim 只有一个「备用文件」概念，无法区分 Helix 的「上次访问」与「上次修改」。
