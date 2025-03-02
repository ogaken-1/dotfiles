local M = {}

local region_start = vim.regex [=[^\s*#region\>\s\+".*"]=]
local region_end = vim.regex [=[^\s*#endregion$]=]

function M.foldexpr(lnum)
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].filetype ~= 'cs' then
    vim.wo.foldmethod = 'manual'
    vim.wo.foldexpr = '0'
    return
  end
  lnum = lnum - 1
  if region_start:match_line(bufnr, lnum) then
    return '>1'
  elseif lnum > 1 and region_end:match_line(bufnr, lnum) then
    return '<1'
  end
  return '='
end

return M
