return {
  'lambdalisue/fern.vim',
  cmd = 'Fern',
  init = function()
    vim.keymap.set('n', '<Space>e', '<Cmd>Fern %:h<CR>')
  end,
}
