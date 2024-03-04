return {
  'nvimtools/none-ls.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'gbprod/none-ls-shellcheck.nvim',
  },
  event = 'FileType',
  config = function()
    local null_ls = require 'null-ls'
    null_ls.register(require 'none-ls-shellcheck.diagnostics')
    null_ls.register(require 'none-ls-shellcheck.code_actions')
    null_ls.setup {
      sources = {
        null_ls.builtins.formatting.stylua,
      },
    }
  end,
}
