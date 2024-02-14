return {
  'uga-rosa/denippet.vim',
  dependencies = {
    'vim-denops/denops.vim',
  },
  config = function()
    vim.fn['denippet#load'](vim.fs.joinpath(vim.fn.stdpath 'config', 'snippets.d', 'lua.toml'))
  end,
}
