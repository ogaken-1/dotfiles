return {
  'mattn/vim-findroot',
  event = { 'BufReadPost', 'BufNewFile' },
  init = function()
    vim.g.findroot_patterns = {
      '.git/',
    }
  end,
}
