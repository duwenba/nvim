-- 你可以在这里添加你自己的插件，或者在这个目录的其他文件里添加！
--  我保证不会在这个目录产生任何合并冲突 :)
--
-- 更多信息请查看 kickstart.nvim README

-- 遍历 plugins 目录中的所有 Lua 文件并加载它们。
-- `vim.fs.dir()` 的遍历顺序是不确定的，不能依赖顺序。
local plugins_dir = vim.fs.joinpath(vim.fn.stdpath 'config', 'lua', 'custom', 'plugins')
for file_name, type in vim.fs.dir(plugins_dir, { follow = true }) do
  if (type == 'file' or type == 'link') and file_name:match '%.lua$' and file_name ~= 'init.lua' then
    local module = file_name:gsub('%.lua$', '')
    require('custom.plugins.' .. module)
  end
end
