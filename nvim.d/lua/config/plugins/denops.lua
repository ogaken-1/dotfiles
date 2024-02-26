return {
  'vim-denops/denops.vim',
  config = function()
    vim.g['denops#server#deno_args'] = { '-q', '--no-lock', '-A' }
  end,
}
