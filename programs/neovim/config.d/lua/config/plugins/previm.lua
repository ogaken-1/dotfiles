return {
  'previm/previm',
  ft = 'markdown',
  init = function()
    if vim.fn.has 'wsl' == 1 then
      vim.g.previm_open_cmd = '/mnt/c/Windows/explorer.exe'
      vim.g.previm_wsl_mode = 1
    end
  end,
}
