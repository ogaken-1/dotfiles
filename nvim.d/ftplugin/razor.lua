vim.cmd.compiler 'dotnet_build'
vim.api.nvim_buf_create_user_command(vim.api.nvim_get_current_buf(), 'OpenCSharp', function()
  local razor_file_name = vim.fn.expand '%:p'
  local csharp_file_name = vim.fn.fnamemodify(razor_file_name, ':r') .. '.razor.cs'
  vim.cmd.edit(csharp_file_name)
end, {})
local function find_file(name)
  local switch = require 'config.switch'
  local files = vim
    .iter(vim.fn.systemlist { 'fd', name })
    :filter(function(item)
      return vim.fn.fnamemodify(item, ':t') == name
    end)
    :totable()
  switch(#files)
    :case(1, function()
      local file = files[1]
      vim.cmd.edit(file)
    end)
    :case(0, function()
      vim.notify('File ' .. name .. ' is not found in current directory.')
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
end
vim.keymap.set('n', 'gd', function()
  local syntax = vim.inspect_pos().syntax
  local hl_group = syntax[#syntax].hl_group
  local cword = vim.fn.expand '<cword>'
  local function is_typename()
    return (hl_group == 'razorRHSIdentifier' or hl_group == 'razorIdentifier')
      and ((vim.fn.expand '<cWORD>'):sub(1, 1) == 'T')
  end
  if
    hl_group == 'razorhtmlTagName'
    or hl_group == 'razorhtmlEndTagName'
    or hl_group == 'razorTypeIdentifier'
    or is_typename()
  then
    find_file(cword .. '.razor')
  elseif hl_group == 'razorcsRHSIdentifier' then
    vim.cmd.OpenCSharp()
    vim.fn.search(([[\V\<%s\>]]):format(cword))
  else
    vim.cmd.normal { 'gd', bang = true }
  end
end, { buffer = true })
