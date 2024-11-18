return {
  'machakann/vim-swap',
  keys = {
    { 'g<', '<Plug>(swap-prev)', mode = 'n' },
    { 'g>', '<Plug>(swap-next)', mode = 'n' },
  },
  init = function()
    vim.g.swap_no_default_key_mappings = true
  end,
}
