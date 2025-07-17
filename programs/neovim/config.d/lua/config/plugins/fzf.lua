return {
  'ibhagwan/fzf-lua',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  cmd = 'FzfLua',
  opts = {
    files = {
      actions = {
        ['ctrl-g'] = false,
      },
    },
    oldfiles = {
      cwd_only = true,
      include_current_session = true,
    },
    blines = {
      fzf_opts = {
        ['--exact'] = true,
        ['--no-sort'] = true,
      },
    },
  },
  keys = {
    '<Plug>(ff)',
    '<Plug>(lsp-references)',
    '<Plug>(lsp-implementations)',
  },
  init = function()
    local builtin_select = vim.ui.select
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.ui.select = function(...)
      vim.ui.select = builtin_select
      vim.cmd.FzfLua 'register_ui_select'
      vim.ui.select(...)
    end
  end,
  config = function(_, opts)
    require('fzf-lua').setup(opts)

    vim.keymap.set('n', '<Plug>(ff)f', require 'config.plugins.fzf.sources.smart-open')
    vim.keymap.set('n', '<Plug>(ff)b', '<Cmd>FzfLua buffers<CR>')
    vim.keymap.set('n', '<Plug>(ff)h', '<Cmd>FzfLua helptags<CR>')
    vim.keymap.set('n', '<Plug>(ff)/', '<Cmd>FzfLua blines<CR>')
    vim.keymap.set('n', '<Plug>(ff)?', '<Cmd>FzfLua live_grep<CR>')

    vim.keymap.set('n', '<Plug>(lsp-references)', '<Cmd>FzfLua lsp_references<CR>')
    vim.keymap.set('n', '<Plug>(lsp-implementations)', '<Cmd>FzfLua lsp_implementations<CR>')
  end,
}
