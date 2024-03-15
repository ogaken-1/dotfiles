return {
  'kana/vim-operator-replace',
  dependencies = {
    'kana/vim-operator-user',
  },
  keys = {
    { 'r', '<Plug>(operator-replace)', mode = { 'x', 'n' } },
  },
}
