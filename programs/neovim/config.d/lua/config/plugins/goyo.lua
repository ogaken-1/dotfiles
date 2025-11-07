return {
  'junegunn/goyo.vim',
  cmd = 'Goyo',
  init = function()
    vim.keymap.set('n', '<C-w><C-o>', '<Cmd>Goyo<CR>')
    vim.g.goyo_width = 130
  end,
}
