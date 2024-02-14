return {
  'lewis6991/gitsigns.nvim',
  event = 'BufReadPost',
  init = function()
    vim.o.signcolumn = 'yes'
  end,
  config = function()
    require('gitsigns').setup {
      on_attach = function(bufnr)
        vim.keymap.set('n', ']c', '<Cmd>Gitsigns next_hunk<CR>', { buffer = bufnr })
        vim.keymap.set('n', '[c', '<Cmd>Gitsigns prev_hunk<CR>', { buffer = bufnr })
        vim.keymap.set('n', '<Space>hs', '<Cmd>Gitsigns stage_hunk<CR>', { buffer = bufnr })
        vim.keymap.set('n', '<Space>hp', '<Cmd>Gitsigns preview_hunk<CR>', { buffer = bufnr })
      end,
    }
  end,
}
