vim.keymap.set('n', ']q', '<Cmd>cnext<CR>')
vim.keymap.set('n', '[q', '<Cmd>cprevious<CR>')
local group_id = vim.api.nvim_create_augroup('config-quickfix', { clear = true })
vim.api.nvim_create_autocmd('QuickFixCmdPost', {
  group = group_id,
  callback = function()
    vim.cmd.cclose()
    vim.cmd.copen { mods = { split = 'belowright' } }
  end,
})
