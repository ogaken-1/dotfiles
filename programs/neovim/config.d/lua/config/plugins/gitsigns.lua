return {
  'lewis6991/gitsigns.nvim',
  event = 'BufReadPost',
  init = function()
    vim.o.signcolumn = 'yes'
  end,
  opts = {
    on_attach = function(bufnr)
      vim.keymap.set('n', ']c', '<Cmd>Gitsigns next_hunk<CR>', { buffer = bufnr })
      vim.keymap.set('n', '[c', '<Cmd>Gitsigns prev_hunk<CR>', { buffer = bufnr })
      vim.keymap.set('n', '<Space>hs', '<Cmd>Gitsigns stage_hunk<CR>', { buffer = bufnr })
      vim.keymap.set('x', '<Space>hs', ':Gitsigns stage_hunk<CR>', { buffer = bufnr })
      vim.keymap.set('n', '<Space>hp', '<Cmd>Gitsigns preview_hunk<CR>', { buffer = bufnr })
      vim.keymap.set('n', '<Space>hb', '<Cmd>Gitsigns blame_line<CR>', { buffer = bufnr })
      vim.keymap.set('n', '<Space>hu', '<Cmd>Gitsigns reset_hunk<CR>', { buffer = bufnr })
    end,
    attach_to_untracked = true,
    diff_opts = {
      algorithm = 'histogram',
      internal = true,
      indent_heuristic = true,
      linematch = 0,
    },
    preview_config = {
      border = 'rounded',
    },
  },
}
