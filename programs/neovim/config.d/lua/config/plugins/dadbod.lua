return {
  'kristijanhusak/vim-dadbod-ui',
  dependencies = {
    { 'tpope/vim-dadbod', lazy = true },
  },
  cmd = {
    'DBUI',
    'DBUIToggle',
    'DBUIAddConnection',
    'DBUIFindBuffer',
  },
  init = function()
    vim.g.db_ui_use_nerd_fonts = 1
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'sql',
      callback = function(ctx)
        vim.keymap.set('n', '<CR>', '<Plug>(DBUI_ExecuteQuery)', { buffer = ctx.buf })
      end,
    })
  end,
}
