return {
  'nvimtools/none-ls.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'gbprod/none-ls-shellcheck.nvim',
  },
  event = 'FileType',
  config = function()
    local null_ls = require 'null-ls'
    local sources = {
      require 'none-ls-shellcheck.diagnostics',
      require 'none-ls-shellcheck.code_actions',
      null_ls.builtins.formatting.stylua,
      null_ls.builtins.formatting.nixfmt,
      null_ls.builtins.xmllint,
    }
    local function add_if(execution, source)
      if 1 == vim.fn.exists(execution) then
        table.insert(sources, source)
      end
    end
    add_if('prettierd', null_ls.builtins.formatting.prettierd)
    null_ls.setup { sources = sources }
  end,
}
