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
    vim.keymap.set('n', '<Plug>(filer:drawer)', '<Cmd>Fern . -drawer -reveal=%<CR>')
  end,
  config = function()
    vim.g['fern#hide_cursor'] = 1
    vim.g['fern#default_hidden'] = 1
    vim.g['fern#renderer'] = 'nerdfont'
    vim.fn['fern_git_status#init']()
    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('config-fern', { clear = true }),
      pattern = 'fern',
      callback = function(ctx)
        vim.keymap.set('n', 'q', '<Cmd>close<CR>', { buffer = ctx.buf })
      end,
    })
  end,
}
