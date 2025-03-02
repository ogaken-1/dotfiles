local assert = require 'config.assert'

local lazypath = vim.fs.joinpath(assert.string(vim.fn.stdpath 'data'), 'lazy', 'lazy.nvim')
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
require('lazy').setup('config.plugins', {
  dev = {
    path = function(plugin)
      return vim.fs.joinpath('~/repos/github.com/ogaken-1', plugin.name)
    end,
    patterns = { 'ogaken-1' },
    fallback = true,
  },
  change_detection = {
    enabled = false,
    notify = false,
  },
})
