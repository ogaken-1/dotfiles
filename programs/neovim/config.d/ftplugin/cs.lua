vim.cmd.compiler 'dotnet_build'
vim.bo.iskeyword = vim.bo.iskeyword .. ',@-@'
vim.keymap.set('n', '<Plug>(run-format)', vim.fn['csharpier#formatfile'], { buffer = true })
vim.api.nvim_buf_create_user_command(vim.api.nvim_get_current_buf(), 'OpenRazor', function()
  local csharp_file_name = vim.fn.expand '%:p'
  local razor_file_name = vim.fn.fnamemodify(csharp_file_name, ':r:r') .. '.razor'
  vim.cmd.edit(razor_file_name)
end, {})
vim.wo.foldmethod = 'expr'
vim.wo.foldexpr = [=[v:lua.require('config.ft.cs').foldexpr(v:lnum)]=]
vim.bo.expandtab = true
vim.bo.shiftwidth = 4
