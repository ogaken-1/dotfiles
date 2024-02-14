return {
  'Shougo/ddc.vim',
  dependencies = {
    'vim-denops/denops.vim',
  },
  init = function()
    vim.api.nvim_create_autocmd('SourcePost', {
      pattern = 'ddc.vim',
      once = true,
      callback = function()
        vim.fn['ddc#custom#patch_global'] {
          sources = {
            require 'config.plugins.ddc.sources.nvim-lsp',
            require 'config.plugins.ddc.sources.buffer',
          },
        }
      end,
    })
  end,
}
