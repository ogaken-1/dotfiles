return {
  'lambdalisue/gin.vim',
  dependencies = {
    'vim-denops/denops.vim',
    'ogaken-1/nvim-gin-preview',
  },
  init = function()
    local prefix = '<Space>a'
    vim.keymap.set('n', prefix .. 'c', '<Cmd>Gin commit<CR>')
    vim.keymap.set('n', prefix .. 'C', '<Cmd>Gin commit --amend<CR>')
    vim.keymap.set('n', prefix .. 'b', '<Cmd>GinBranch<CR>')
    vim.keymap.set('n', prefix .. 'h', '<Cmd>GinLog --graph<CR>')
    vim.keymap.set('n', prefix .. 'H', '<Cmd>GinLog --follow -- %<CR>')
    vim.g.gin_log_persistent_args = {
      '++emojify',
      '--format=%C(green)%h%C(reset) %s %C(bold yellow)%cr%C(reset) %C(bold magenta)<%an>%C(reset) %C(auto)%d%C(reset)',
      '--abbrev-commit',
      '--max-count=150',
    }
    vim.g.gin_proxy_apply_without_confirm = true
    vim.api.nvim_create_autocmd('BufWinEnter', {
      once = true,
      callback = function()
        vim.fn['denops#plugin#wait_async']('gin', function()
          if vim.fn.bufname() ~= '' then
            return
          end
          vim.cmd.GinStatus()
        end)
      end,
    })
  end,
}
