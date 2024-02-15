return {
  'machakann/vim-sandwich',
  keys = {
    { 'sa', '<Plug>(sandwich-add)', mode = { 'n', 'x' } },
    { 'sd', '<Plug>(sandwich-delete)' },
    { 'sdb', '<Plug>(sandwich-delete-auto)' },
    { 'sr', '<Plug>(sandwich-replace)' },
    { 'srb', '<Plug>(sandwich-replace-auto)' },
    { 'ib', '<Plug>(textobj-sandwich-auto-i)', mode = { 'x', 'o' } },
    { 'ab', '<Plug>(textobj-sandwich-auto-a)', mode = { 'x', 'o' } },
  },
  init = function()
    vim.g.sandwich_no_default_key_mappings = 1
  end,
  config = function()
    vim.g['sandwich#magicchar#f#patterns'] = {
      {
        header = [[\<\%(\h\k*\.\)*\h\k*]],
        bra = '(',
        ket = ')',
        footer = '',
      },
    }
  end,
}
