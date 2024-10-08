local fern = {
  'lambdalisue/fern.vim',
  cmd = 'Fern',
  dependencies = {
    'lambdalisue/vim-fern-git-status',
  },
  init = function()
    vim.keymap.set('n', '<Space>e', function()
      if vim.go.columns < 200 then
        local bufnr = vim.api.nvim_get_current_buf()
        ---@type string
        local dir
        if vim.api.nvim_get_option_value('buftype', { buf = bufnr }) == '' then
          dir = '%:h'
        else
          dir = '.'
        end
        vim.cmd.Fern(dir)
        return
      else
        vim.cmd.Fern { '.', '-drawer', '-reveal=%' }
        return
      end
    end)
  end,
  config = function()
    vim.g['fern#hide_cursor'] = 1
    vim.g['fern#default_hidden'] = 1
    vim.fn['fern_git_status#init']()
  end,
}
local fern_hijack = {
  'lambdalisue/vim-fern-hijack',
}

return { fern, fern_hijack }
