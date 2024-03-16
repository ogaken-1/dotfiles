return {
  'hrsh7th/nvim-cmp',
  event = 'InsertEnter',
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'uga-rosa/cmp-denippet',
    'uga-rosa/cmp-skkeleton',
  },
  config = function()
    local cmp = require 'cmp'
    cmp.setup {
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
        { name = 'skkeleton' },
      }, {
        { name = 'denippet' },
        { name = 'nvim_lsp' },
      }, {
        { name = 'buffer' },
      }),
      experimental = {
        ghost_text = true,
      },
    }
  end,
}
