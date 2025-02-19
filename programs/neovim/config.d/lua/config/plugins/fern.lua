local fern = {
  'lambdalisue/fern.vim',
  cmd = 'Fern',
  dependencies = {
    'lambdalisue/vim-fern-git-status',
  },
  config = function()
    vim.g['fern#hide_cursor'] = 1
    vim.g['fern#default_hidden'] = 1
    vim.fn['fern_git_status#init']()
  end,
}
local fern_hijack = {
  'lambdalisue/vim-fern-hijack',
  enabled = false,
}

return { fern, fern_hijack }
