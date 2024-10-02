return {
  'kana/vim-textobj-entire',
  dependencies = {
    'kana/vim-textobj-user',
  },
  keys = {
    { 'ae', '<Plug>(textobj-entire-a)', mode = { 'x', 'o' } },
    { 'ie', '<Plug>(textobj-entire-i)', mode = { 'x', 'o' } },
  },
}
