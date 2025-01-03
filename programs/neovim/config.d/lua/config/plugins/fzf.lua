return {
  'ibhagwan/fzf-lua',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  cmd = 'FzfLua',
  init = function()
    vim.keymap.set('n', 'U', '<C-r>')
    vim.keymap.set('n', '<C-p>', '<Cmd>FzfLua files<CR>')
    vim.keymap.set('n', '<C-h>', '<Cmd>FzfLua help_tags<CR>')
    vim.keymap.set('n', '<C-s>', '<Cmd>FzfLua blines<CR>')
    vim.keymap.set('n', '<C-r>', '<Cmd>FzfLua oldfiles<CR>')
    vim.keymap.set('n', '<C-g>', '<Cmd>FzfLua grep_cword<CR>')
  end,
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
  },
}
