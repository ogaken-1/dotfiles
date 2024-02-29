local confirm = require 'config.confirm'
local function nmap(lhs, rhs)
  vim.keymap.set('n', lhs, rhs, { buffer = true })
end
local function push(flags)
  return function()
    if confirm 'Push to remote?' then
      local cmd = flags or {}
      table.insert(cmd, 1, 'push')
      vim.cmd.Gin(cmd)
    else
      vim.notify 'Push canceled.'
    end
  end
end

local prefix = {
  push = 'p',
  fetch = 'f',
  commit = 'c',
}

nmap(prefix.push .. 'p', push())
nmap(prefix.push .. 'f', push { '--force-if-includes', '--force-with-lease' })
nmap(prefix.fetch .. 'f', '<Cmd>Gin fetch --prune<CR>')
nmap(prefix.fetch .. 'm', function()
  if confirm 'Pull remote?' then
    vim.cmd.Gin { 'pull', '--autostash', '--prune' }
  else
    vim.notify 'Pull canceled.'
  end
end)
nmap(prefix.commit .. 'c', '<Cmd>Gin commit<CR>')
nmap(prefix.commit .. 'a', '<Cmd>Gin commit --amend<CR>')
