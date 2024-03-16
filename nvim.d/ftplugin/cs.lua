vim.cmd.compiler 'dotnet_build'
vim.bo.iskeyword = vim.bo.iskeyword .. ',@-@'
vim.keymap.set('n', 'mf', vim.fn['csharpier#formatfile'])
vim.api.nvim_buf_create_user_command(vim.api.nvim_get_current_buf(), 'OpenRazor', function()
  local csharp_file_name = vim.fn.expand '%:p'
  local razor_file_name = vim.fn.fnamemodify(csharp_file_name, ':r:r') .. '.razor'
  vim.cmd.edit(razor_file_name)
end, {})
