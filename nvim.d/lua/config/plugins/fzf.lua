return {
  'ibhagwan/fzf-lua',
  cmd = 'FzfLua',
  init = function()
    vim.keymap.set('n', 'U', '<C-r>')
    vim.keymap.set('n', '<C-p>', '<Cmd>FzfLua files<CR>')
    vim.keymap.set('n', '<C-h>', '<Cmd>FzfLua help_tags<CR>')
    vim.keymap.set('n', '<C-s>', '<Cmd>FzfLua blines<CR>')
    vim.keymap.set('n', '<C-n>', '<Cmd>FzfLua buffers<CR>')
    vim.keymap.set('n', '<C-r>', '<Cmd>FzfLua oldfiles<CR>')
  end,
  end,
}
