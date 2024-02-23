local M = {}

local function read_file(fname)
  local content = vim.fn.join(vim.fn.readfile(fname))
  return vim.json.decode(content)
end

---@param x table
---@return table
local function expand(x)
  local t = {}
  for k, v in pairs(x) do
    if type(v) == 'string' then
      t[k] = v
    elseif type(v) == 'table' then
      for k1, v1 in pairs(expand(v)) do
        t[k .. k1] = v1
      end
    else
      error(type(v) .. ' is not expected')
    end
  end
  return t
end

local function build(kana_table)
  local keyToKana = expand(kana_table)
  local skkeleton_kanaTable = {}
  for k, v in pairs(keyToKana) do
    skkeleton_kanaTable[k] = { v }
  end
  return skkeleton_kanaTable
end

function M.load()
  vim.fn['denops#plugin#wait_async']('skkeleton', function()
    local file_name = vim.fs.joinpath(vim.fn.stdpath 'config', 'kana-table.json')
    local kana_table = read_file(file_name)
    local skkeleton_kanaTable = build(kana_table)
    vim.fn['skkeleton#register_kanatable']('azik', skkeleton_kanaTable, true)
  end)
end

return M
