local fn = vim.fn

vim.loader.enable()
local lazypath = vim.fs.joinpath(vim.fn.stdpath 'data', 'lazy', 'lazy.nvim')
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)
require('lazy').setup 'config.plugins'

do
  vim.keymap.set({ 'n', 'x' }, ';', '<Nop>')
  vim.keymap.set({ 'n', 'x' }, '<Plug>(submode-f);', ';<Plug>(submode-f)')
  vim.keymap.set({ 'n', 'x' }, 'f', function()
    local char = fn.nr2char(fn.getchar())
    return 'f' .. char .. '<Plug>(submode-f)'
  end, { expr = true })
end

do
  vim.cmd.colorscheme 'habamax'
end

-- vim:ft=lua et ts=2 sw=2
