return {
  'lambdalisue/fern.vim',
  cmd = 'Fern',
  dependencies = {
    'lambdalisue/vim-fern-git-status',
    'lambdalisue/vim-fern-renderer-nerdfont',
    'lambdalisue/vim-nerdfont',
    { 'lambdalisue/vim-fern-hijack', lazy = false },
  },
  init = function()
    vim.keymap.set('n', '<Space>e', '<Cmd>Fern %:h<CR>')
    vim.keymap.set('n', '<Space>E', '<Cmd>Fern . -reveal=%<CR>')
  end,
  config = function()
    vim.g['fern#hide_cursor'] = 1
    vim.g['fern#default_hidden'] = 1
    vim.g['fern#renderer'] = 'nerdfont'
    vim.fn['fern_git_status#init']()
  end,
}
