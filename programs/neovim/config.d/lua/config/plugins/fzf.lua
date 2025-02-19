return {
  'ibhagwan/fzf-lua',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  cmd = 'FzfLua',
  opts = {
    files = {
      actions = {
        ['ctrl-g'] = false,
      },
    },
    oldfiles = {
      cwd_only = true,
      include_current_session = true,
    },
  },
}
