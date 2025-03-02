---@param lhs string
---@param rhs string
---@return nil
local function abbr_cmdline(lhs, rhs)
  vim.keymap.set('ca', lhs, function()
    local cmdtype = vim.fn.getcmdtype()
    if cmdtype ~= ':' then
      return lhs
    end
    local cmdline = vim.fn.getcmdline()
    return cmdline == lhs and rhs or lhs
  end, { expr = true })
end

-- cmdlineモードでの補完候補の選択には<Tab>を使うので<C-[pn]>は空けて良い。
-- <Up>/<Down>はカーソル前の入力をリスペクトするのでそちらを使う。
vim.keymap.set('c', '<C-p>', '<Up>')
vim.keymap.set('c', '<C-n>', '<Down>')
abbr_cmdline('w', 'update')
abbr_cmdline('wq', 'exit')
