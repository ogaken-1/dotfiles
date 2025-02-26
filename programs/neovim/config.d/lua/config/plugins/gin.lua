return {
  'lambdalisue/gin.vim',
  dependencies = {
    'vim-denops/denops.vim',
    'ogaken-1/nvim-gin-preview',
  },
  init = function()
    vim.keymap.set('n', '<Plug>(git)c', '<Cmd>Gin commit<CR>')
    vim.keymap.set('n', '<Plug>(git)C', '<Cmd>Gin commit --amend<CR>')
    vim.keymap.set('n', '<Plug>(git)h', '<Cmd>GinLog --graph<CR>')
    vim.keymap.set('n', '<Plug>(git)H', '<Cmd>GinLog --follow -- %<CR>')
    vim.g.gin_log_persistent_args = {
      '++emojify',
      '--format=%C(green)%h%C(reset) %s %C(bold yellow)%cr%C(reset) %C(bold magenta)<%an>%C(reset) %C(auto)%d%C(reset)',
      '--abbrev-commit',
      '--max-count=150',
    }
    vim.g.gin_proxy_apply_without_confirm = true
    vim.keymap.set('ca', 'cq', function()
      local cmdtype = vim.fn.getcmdtype()
      if cmdtype ~= ':' then
        return 'cq'
      end
      local buffer_commands = vim.api.nvim_buf_get_commands(0, {})
      local cmdline = vim.fn.getcmdline()
      return cmdline == 'cq' and (buffer_commands['Cancel'] == nil and 'cq' or 'Cancel') or 'cq'
    end, { expr = true })
  end,
}
