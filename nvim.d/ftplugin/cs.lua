vim.cmd.compiler 'dotnet_build'
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
      local ans = vim.fn.input 'Unsaved buffer exists. Save files and run format? [Y/n] '
      if vim.regex([=[^[Yy]\(es\)\?$]=]):match_str(ans) then
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
