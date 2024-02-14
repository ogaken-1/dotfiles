return {
  'https://github.com/nvimtools/none-ls.nvim.git',
  dependencies = {
    'https://github.com/nvim-lua/plenary.nvim.git',
  },
  event = {
    'BufReadPost',
    'BufNewFile',
  },
  config = function()
    local null_ls = require 'null-ls'
    null_ls.setup {
      sources = {
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.diagnostics.shellcheck.with {
          extra_args = function(params)
            return { '--exclude', 'SC2148' }
          end,
          extra_filetypes = { 'zsh' },
        },
        -- null_ls.builtins.diagnostics.markdownlint,
      },
    }
  end,
}
