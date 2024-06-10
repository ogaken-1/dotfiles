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
    local sources = {}
    local function add(source)
      table.insert(sources, source)
    end
    local function add_if_exists(cmd, source)
      if vim.fn.executable(cmd) == 1 then
        add(source)
      end
    end
    add_if_exists('prettierd', null_ls.builtins.formatting.prettierd)
    add_if_exists('stylua', null_ls.builtins.formatting.stylua)
    null_ls.setup { sources = sources }
  end,
}
