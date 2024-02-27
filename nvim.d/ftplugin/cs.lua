vim.cmd.compiler 'dotnet_build'
if vim.env.TMUX ~= nil then
  vim.keymap.set('n', '<Plug>(run-format)', function()
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
