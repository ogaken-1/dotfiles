return {
  'lambdalisue/gin.vim',
  dependencies = {
    'vim-denops/denops.vim',
  },
  init = function()
    local prefix = '<Space>a'
    vim.keymap.set('n', prefix .. 'a', '<Cmd>GinStatus<CR>')
    vim.keymap.set('n', prefix .. 'c', '<Cmd>Gin commit -v<CR>')
    vim.keymap.set('n', prefix .. 'C', '<Cmd>Gin commit -v --amend<CR>')
    vim.keymap.set('n', prefix .. 'b', '<Cmd>GinBranch<CR>')
    vim.keymap.set('n', prefix .. 'h', '<Cmd>GinLog<CR>')
    vim.keymap.set('n', prefix .. 'H', '<Cmd>GinLog -- %<CR>')
    vim.g.gin_log_persistent_args = {
      '++emojify',
      '--format=%C(green)%h%C(reset) %s %C(bold yellow)%cr%C(reset) %C(bold magenta)<%an>%C(reset) %C(auto)%d%C(reset)',
      '--abbrev-commit',
      '--max-count=150',
    }
    local gid = vim.api.nvim_create_augroup('gin-config', { clear = true })
    vim.api.nvim_create_autocmd('BufWinEnter', {
      group = gid,
      desc = 'Change cwd to git root of cbuf automatically.',
      callback = function(ctx)
        if vim.fn.bufname(ctx.buf) ~= '' and vim.bo[ctx.buf].buftype == '' then
          vim.fn['denops#plugin#wait_async']('gin', vim.cmd.GinLcd)
        end
      end,
    })
  end,
}
