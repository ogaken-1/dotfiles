return {
  '4513ECHO/vim-snipewin',
  keys = { '<Plug>(snipewin)' },
  init = function()
    vim.keymap.set('n', '<C-w><C-w>', function()
      local focusable_wins = vim
        .iter(vim.api.nvim_tabpage_list_wins(0))
        :filter(function(winid)
          return vim.api.nvim_win_get_config(winid).focusable
        end)
        :totable()
      if #focusable_wins <= 2 then
        return '<C-w><C-w>'
      end
      return '<Plug>(snipewin)'
    end, { expr = true })
  end,
}
