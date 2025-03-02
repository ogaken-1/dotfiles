vim.loader.enable()

require 'config.plugin-loader'
require 'config.commands'
require 'config.lsp'
require 'config.cmdline'
require 'config.normal'
require 'config.opts'
require 'config.quickfix'

vim.cmd.colorscheme(vim.env.NVIM_COLORSCHEME or 'momiji')

vim.filetype.add {
  extension = {
    tsp = 'typespec',
    razor = 'razor',
  },
  filename = {
    ['nuget.config'] = 'xml',
  },
  pattern = {
    ['Directory..+.props'] = 'xml',
  },
}

-- vim:ft=lua et ts=2 sw=2
