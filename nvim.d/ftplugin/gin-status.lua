local function nmap(lhs, rhs)
  vim.keymap.set('n', lhs, rhs, { buffer = true })
end
local function push(flags)
  return function()
    local input = vim.fn.input { prompt = 'Push to remote? [Y/n] ' }
    if vim.regex([=[^[Yy]\(es\)\?]=]):match_str(input) then
      local cmd = flags or {}
      table.insert(cmd, 1, 'push')
      vim.cmd.Gin(cmd)
    else
      vim.notify 'Push canceled.'
    end
  end
end

local prefix = {
  push = 'P',
  fetch = 'f',
  commit = 'c',
}

nmap(prefix.push .. 'p', push())
nmap(prefix.push .. 'f', push { '--force-if-includes', '--force-with-lease' })
nmap(prefix.fetch .. 'f', '<Cmd>Gin fetch --prune<CR>')
nmap(prefix.fetch .. 'm', '<Cmd>Gin pull --autostash --prune<CR>')
nmap(prefix.commit .. 'c', '<Cmd>Gin commit<CR>')
nmap(prefix.commit .. 'a', '<Cmd>Gin commit --amend<CR>')
