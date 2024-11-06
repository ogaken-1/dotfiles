---@class config.CommandParams
---@field name string
---@field args string
---@field fargs table
---@field nargs string
---@field bang boolean
---@field line1 number
---@field line2 number
---@field range number
---@field count number
---@field reg string
---@field mods string
---@field smods table

---@class config.CommandDef
---@field action fun(params: config.CommandParams)
---@field opts  vim.api.keyset.user_command

local files = vim.fn.readdir(vim.fs.joinpath(vim.fn.stdpath 'config', 'lua', 'config', 'commands'))
local mods = vim
  .iter(files)
  :map(function(fname)
    return vim.fn.fnamemodify(fname, ':r')
  end)
  :totable()

for _, name in ipairs(mods) do
  vim.api.nvim_create_user_command(name, function(params)
    local mod = require(('config.commands.%s'):format(name))
    vim.api.nvim_create_user_command(name, mod.action, mod.opts)
    mod.action(params)
  end, { nargs = '*' })
end
