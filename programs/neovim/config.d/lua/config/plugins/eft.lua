return {
  'hrsh7th/vim-eft',
  keys = {
    { 'f', '<Plug>(eft-f)', mode = { 'n', 'x', 'o' } },
    { 'F', '<Plug>(eft-F)', mode = { 'n', 'x', 'o' } },
    { 't', '<Plug>(eft-t)', mode = { 'n', 'x', 'o' } },
    { 'T', '<Plug>(eft-T)', mode = { 'n', 'x', 'o' } },
    { ';', '<Plug>(eft-repeat)', mode = { 'n', 'x' } },
  },
  init = function()
    vim.g.eft_ignorecase = true
  end,
}
