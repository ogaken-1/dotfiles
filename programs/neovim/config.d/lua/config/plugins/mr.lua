return {
  'lambdalisue/vim-mr',
  event = { 'BufWritePre' }, -- mrwを使いたいのでBufWritePreには欲しい
  -- `vim.fn[mr#*]` が実行されたときにロードする
  init = function(plugin)
    vim.api.nvim_create_autocmd('FuncUndefined', {
      once = true,
      pattern = 'mr#*',
      callback = function()
        require('lazy').load { plugins = { plugin } }
      end,
    })
  end,
}
