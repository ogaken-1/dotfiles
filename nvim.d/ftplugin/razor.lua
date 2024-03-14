vim.cmd.compiler 'dotnet_build'
vim.api.nvim_buf_create_user_command(vim.api.nvim_get_current_buf(), 'OpenCSharp', function()
  local razor_file_name = vim.fn.expand '%:p'
  local csharp_file_name = vim.fn.fnamemodify(razor_file_name, ':r') .. '.razor.cs'
  vim.cmd.edit(csharp_file_name)
end, {})
vim.keymap.set('n', 'gd', function()
  local switch = require 'config.switch'
  local file_name = (vim.fn.expand '<cword>')
  local files = vim.fn.systemlist { 'fd', '-e', 'razor', file_name }
  switch(#files)
    :case(1, function()
      local file = files[1]
      vim.cmd.edit(file)
    end)
    :case(0, function()
      vim.notify('File ' .. file_name .. ' is not found in current directory.')
    end)
    :default(function()
      local qf_items = {}
      for i, file in ipairs(files) do
        qf_items[i] = {
          filename = file,
          text = file,
        }
      end
      vim.fn.setqflist({}, 'r', { items = qf_items })
      vim.cmd.copen()
    end)
    :eval()
end, { buffer = true })
