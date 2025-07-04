return {
  'Shougo/vinarise.vim',
  cmd = 'Vinarise',
  event = { 'BufReadPost', 'FileReadPost' },
  init = function()
    vim.g.vinarise_enable_auto_detect = 1
  end,
}
