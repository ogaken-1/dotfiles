local function find_and_open_file(name)
  local switch = require 'config.switch'
  local files = vim
    .iter(vim.fn.systemlist { 'fd', name, '-e', 'razor', '-e', 'cs', '-t', 'file' })
    :filter(function(item)
      return vim.fn.fnamemodify(item, ':t:r') == name
    end)
    :totable()
  switch(#files)
    :case(1, function()
      local file = files[1]
      vim.cmd.edit(file)
    end)
    :case(0, function()
      vim.notify('File ' .. name .. ' is not found in ' .. vim.fn.getcwd())
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

local function goto_definition()
  local treesitter = vim.inspect_pos().treesitter[1]
  if treesitter == nil then
    return
  end
  local capture = treesitter.capture
  local cword = vim.fn.expand '<cword>'
  local function is_typename()
    return (capture == 'variable' or capture == 'variable') and ((vim.fn.expand '<cWORD>'):sub(1, 1) == 'T')
  end
  if capture == 'tag' or capture == 'type' or is_typename() then
    find_and_open_file(cword)
  elseif capture == 'variable' then
    vim.cmd.OpenCSharp()
    vim.fn.search(([[\V\<%s\>]]):format(cword))
  else
    vim.cmd.normal { 'gd', bang = true }
  end
end

local M = {}

function M.setup(bufnr)
  if bufnr == nil then
    return
  end
  vim.keymap.set('n', 'gd', goto_definition, { buffer = bufnr })
  vim.api.nvim_buf_create_user_command(bufnr, 'OpenCSharp', function()
    local razor_file_name = vim.fn.expand '%:p'
    local csharp_file_name = vim.fn.fnamemodify(razor_file_name, ':r') .. '.razor.cs'
    vim.cmd.edit(csharp_file_name)
  end, {})
end

return M
