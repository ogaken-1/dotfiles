return {
  'mattn/vim-findroot',
  events = { 'BufReadPost', 'BufNewFile' },
  init = function()
    vim.g.findroot_patterns = {
      '.git/',
    }
  end,
}
