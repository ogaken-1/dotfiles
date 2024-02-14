return {
  'hrsh7th/nvim-cmp',
  event = 'InsertEnter',
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'uga-rosa/cmp-denippet',
  },
  config = function()
    local cmp = require 'cmp'
    cmp.setup {
      enabled = function()
        return vim.fn['skkeleton#mode']() == ''
      end,
      snippet = {
        expand = function(args)
          vim.snippet.expand(args.body)
        end,
      },
      window = {
        completion = {
          border = 'single',
        },
        documentation = {
          border = 'single',
        },
      },
      sources = cmp.config.sources({
        { name = 'denippet' },
        { name = 'nvim_lsp' },
      }, {
        { name = 'buffer' },
      }),
    }
  end,
}
