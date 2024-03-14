vim.cmd.compiler 'dotnet_build'
vim.bo.iskeyword = vim.bo.iskeyword .. ',@-@'
if vim.env.TMUX ~= nil then
  vim.keymap.set('n', '<Plug>(run-format)', function()
    local ok = true
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      ok = ok and not vim.bo[buf].modified
      if not ok then
        break
      end
    end
    if not ok then
      local confirm = require 'config.confirm'
      if confirm 'Unsaved buffer exists. Save files and run format?' then
        vim.cmd '%update'
      else
        vim.print 'Formatting canceled.'
        return
      end
    end
    vim.fn.system {
      'tmux',
      'split-window',
      '-v',
      '-l',
      '5',
      'dotnet csharpier .;sleep 2',
    }
  end, { buffer = true })
end
vim.api.nvim_buf_create_user_command(vim.api.nvim_get_current_buf(), 'OpenRazor', function()
  local csharp_file_name = vim.fn.expand '%:p'
  local razor_file_name = vim.fn.fnamemodify(csharp_file_name, ':r:r') .. '.razor'
  vim.cmd.edit(razor_file_name)
end, {})
