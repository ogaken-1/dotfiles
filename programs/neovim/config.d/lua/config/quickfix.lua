vim.keymap.set('n', ']q', '<Cmd>cnext<CR>')
vim.keymap.set('n', '[q', '<Cmd>cprevious<CR>')
vim.api.nvim_create_autocmd('QuickFixCmdPost', {
  group = vim.api.nvim_create_augroup('config-quickfix', { clear = true }),
  callback = function()
    vim.cmd.cclose()
    vim.cmd.copen { mods = { split = 'belowright' } }
  end,
})
