return {
  'stevearc/aerial.nvim',
  cmd = { 'AerialOpen', 'AerialNext', 'AerialPrev' },
  init = function()
    vim.keymap.set('n', '<Space>i', function()
      vim.cmd.AerialOpen 'float'
      -- workaround
      -- see: https://github.com/stevearc/aerial.nvim/issues/331#issuecomment-1939760914
      vim.cmd.doautocmd 'BufWinEnter'
    end)
    vim.keymap.set('n', '<A-j>', '<Cmd>AerialNext<CR>')
    vim.keymap.set('n', '<A-k>', '<Cmd>AerialPrev<CR>')
    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('config-aerial', { clear = false }),
      pattern = { 'gin', 'gin-diff' },
      callback = function(ctx)
        vim.keymap.set('n', '<Space>i', '<Cmd>AerialOpen left<CR>', { buffer = ctx.buf })
      end,
    })
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
      filter_kind = {
        'Class',
        'Constructor',
        'Enum',
        'Function',
        'Interface',
        'Module',
        'Method',
        'Struct',
        'Property',
        'File',
      },
      ignore = {
        buftypes = {},
      },
    }
  end,
}
