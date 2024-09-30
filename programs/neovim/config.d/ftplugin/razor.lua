vim.cmd.compiler 'dotnet_build'
vim.api.nvim_buf_create_user_command(vim.api.nvim_get_current_buf(), 'OpenCSharp', function()
  local razor_file_name = vim.fn.expand '%:p'
  local csharp_file_name = vim.fn.fnamemodify(razor_file_name, ':r') .. '.razor.cs'
  vim.cmd.edit(csharp_file_name)
end, {})
