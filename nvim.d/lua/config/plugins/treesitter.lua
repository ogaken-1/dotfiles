return {
  'nvim-treesitter/nvim-treesitter',
  event = 'BufReadPost',
  config = function()
    vim.opt.rtp:prepend(vim.fs.joinpath(vim.fn.stdpath 'data', 'treesitter'))
    require('nvim-treesitter.configs').setup {
      ensure_installed = {
        'lua',
      },
      highlight = {
        enable = true,
      },
    }
  end,
}
