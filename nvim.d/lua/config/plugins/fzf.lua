return {
  'ibhagwan/fzf-lua',
  cmd = 'FzfLua',
  init = function()
    vim.keymap.set('n', ';f', '<Cmd>FzfLua files<CR>')
    vim.keymap.set('n', ';h', '<Cmd>FzfLua help_tags<CR>')
    vim.keymap.set('n', ';s', '<Cmd>FzfLua blines<CR>')
  end,
}
