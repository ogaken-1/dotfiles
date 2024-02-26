return {
  'lambdalisue/gin.vim',
  dependencies = {
    'vim-denops/denops.vim',
  },
  init = function()
    local prefix = '<Space>a'
    vim.keymap.set('n', prefix .. 'a', '<Cmd>GinStatus<CR>')
    vim.keymap.set('n', prefix .. 'b', '<Cmd>GinBranch<CR>')
    vim.keymap.set('n', prefix .. 'h', '<Cmd>GinLog --graph<CR>')
    vim.keymap.set('n', prefix .. 'H', '<Cmd>GinLog --follow -- %<CR>')
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
        local function is_normal_buffer()
          return vim.fn.bufname(ctx.buf) ~= '' and vim.bo[ctx.buf].buftype == ''
        end
        if is_normal_buffer() then
          vim.fn['denops#plugin#wait_async']('gin', vim.cmd.GinLcd)
        end
      end,
    })
  end,
}
