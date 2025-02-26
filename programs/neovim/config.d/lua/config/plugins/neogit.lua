return {
  'NeogitOrg/neogit',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'sindrets/diffview.nvim',
  },
  cmd = 'Neogit',
  opts = {},
  keys = {
    { '<Plug>(git)a', '<Cmd>Neogit<CR>' },
  },
}
