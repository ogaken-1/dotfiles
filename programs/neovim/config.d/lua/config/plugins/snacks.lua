return {
  'folke/snacks.nvim',
  opts = {},
  init = function()
    vim.keymap.set('n', '<Space>aa', function()
      require('snacks').lazygit()
    end)
    vim.keymap.set('n', '<Space>ah', function()
      require('snacks').lazygit.log()
    end)
    vim.keymap.set('n', '<Space>aH', function()
      require('snacks').lazygit.log_file()
    end)
  end,
}
