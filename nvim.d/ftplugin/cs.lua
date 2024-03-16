if vim.b.did_my_ftplugin == 1 then
  return
end
vim.b.did_my_ftplugin = 1

vim.cmd.compiler 'dotnet_build'
vim.bo.iskeyword = vim.bo.iskeyword .. ',@-@'
vim.fn['denops#notify']('csharpier', 'startServer', {})
local function format_cbuf()
  vim.fn['denops#request']('csharpier', 'format', { vim.api.nvim_get_current_buf() })
end
vim.keymap.set('n', 'mf', format_cbuf)
vim.api.nvim_create_autocmd('BufWritePre', {
  buffer = vim.api.nvim_get_current_buf(),
  callback = format_cbuf,
})
vim.api.nvim_buf_create_user_command(vim.api.nvim_get_current_buf(), 'OpenRazor', function()
  local csharp_file_name = vim.fn.expand '%:p'
  local razor_file_name = vim.fn.fnamemodify(csharp_file_name, ':r:r') .. '.razor'
  vim.cmd.edit(razor_file_name)
end, {})
