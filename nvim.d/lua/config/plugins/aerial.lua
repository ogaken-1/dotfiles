return {
  'stevearc/aerial.nvim',
  cmd = 'AerialOpen',
  init = function()
    vim.keymap.set('n', '<Space>i', function()
      vim.cmd.AerialOpen 'float'
      -- workaround
      -- see: https://github.com/stevearc/aerial.nvim/issues/331#issuecomment-1939760914
      vim.cmd.doautocmd 'BufWinEnter'
    end)
  end,
  config = function()
    require('aerial').setup {
      layout = {
        default_direction = 'float',
        max_width = { 80, 0.5 },
        width = nil,
        min_width = 20,
        win_opts = {
          winblend = 30,
        },
        placement = 'edge',
      },
      close_automatic_events = { 'unfocus', 'switch_buffer' },
      float = {
        border = 'rounded',
        relative = 'win',
        max_height = 0.9,
        height = nil,
        min_height = { 8, 0.1 },
        override = function(conf, source_winid)
          conf.anchor = 'NE'
          conf.col = vim.fn.winwidth(source_winid)
          conf.row = 0
          return conf
        end,
      },
    }
  end,
}
