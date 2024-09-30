local M = {}

---@param lhs string
---@param rhs string
---@return nil
function M.abbr_cmdline(lhs, rhs)
  vim.keymap.set('ca', lhs, function()
    local cmdtype = vim.fn.getcmdtype()
    if cmdtype ~= ':' then
      return lhs
    end
    local cmdline = vim.fn.getcmdline()
    return cmdline == lhs and rhs or lhs
  end, { expr = true })
end

return M
