return {
  '4513ECHO/vim-snipewin',
  keys = { '<Plug>(snipewin)' },
  init = function()
    vim.keymap.set('n', '<C-w><C-w>', function()
      if #vim.api.nvim_tabpage_list_wins(0) <= 2 then
        return '<C-w><C-w>'
      end
      return '<Plug>(snipewin)'
    end, { expr = true })
  end,
}
