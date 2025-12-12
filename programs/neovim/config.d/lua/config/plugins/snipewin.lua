local function invoke_snipewin_if_wins_morethan_3(key, action)
  return function()
    local focusable_wins = vim
      .iter(vim.api.nvim_tabpage_list_wins(0))
      :filter(function(winid)
        return vim.api.nvim_win_get_config(winid).focusable
      end)
      :totable()
    if #focusable_wins <= 2 then
      vim.cmd.normal { bang = true, key }
      return
    end
    local snipewin = require 'snipewin'
    snipewin.select(snipewin.callback[action])
  end
end
return {
  '4513ECHO/vim-snipewin',
  lazy = true,
  init = function()
    vim.keymap.set('n', '<C-w><C-w>', invoke_snipewin_if_wins_morethan_3('<C-w><C-w>', 'goto'))
    vim.keymap.set('n', '<C-w>r', invoke_snipewin_if_wins_morethan_3('<C-w><C-w>', 'swap'))
  end,
}
