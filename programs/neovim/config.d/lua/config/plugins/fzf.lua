return {
  'ibhagwan/fzf-lua',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  cmd = 'FzfLua',
  init = function()
    vim.keymap.set('n', 'U', '<C-r>')
    local prefix = '<Space>f'
    local function with_prefix(char)
      return prefix .. char
    end
    vim.keymap.set('n', with_prefix 'f', '<Cmd>FzfLua files<CR>')
    vim.keymap.set('n', with_prefix 'h', '<Cmd>FzfLua help_tags<CR>')
    vim.keymap.set('n', with_prefix 'l', '<Cmd>FzfLua blines<CR>')
    vim.keymap.set('n', with_prefix 'o', '<Cmd>FzfLua oldfiles<CR>')
    vim.keymap.set('n', with_prefix 'g', '<Cmd>FzfLua grep_cword<CR>')
    vim.keymap.set('n', with_prefix 'b', '<Cmd>FzfLua buffers<CR>')
  end,
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
