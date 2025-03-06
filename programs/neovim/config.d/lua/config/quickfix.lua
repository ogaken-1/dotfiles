vim.keymap.set('n', ']q', '<Cmd>cnext<CR>')
vim.keymap.set('n', '[q', '<Cmd>cprevious<CR>')
local augroup = vim.api.nvim_create_augroup('config-quickfix', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'qf',
  group = augroup,
  callback = function(ctx)
    vim.keymap.set('n', 'q', vim.cmd.cclose, { buffer = ctx.buf })
  end,
})
vim.api.nvim_create_autocmd('QuickFixCmdPost', {
  group = augroup,
  callback = function()
    vim.cmd.cclose()
    vim.cmd.copen { mods = { split = 'belowright' } }
  end,
})
