local fn = vim.fn

vim.loader.enable()
local lazypath = vim.fs.joinpath(vim.fn.stdpath 'data', 'lazy', 'lazy.nvim')
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)
require('lazy').setup 'config.plugins'

do
  vim.keymap.set({ 'n', 'x' }, ';', '<Nop>')
  vim.keymap.set({ 'n', 'x' }, '<Plug>(submode-f);', ';<Plug>(submode-f)')
  local function jump_and_enter_submode(key)
    return function()
      local char = fn.getcharstr()
      return key .. char .. '<Plug>(submode-f)'
    end
  end
  for _, key in ipairs { 'f', 'F', 't', 'T' } do
    vim.keymap.set({ 'n', 'x' }, key, jump_and_enter_submode(key), { expr = true })
  end

  vim.keymap.set('n', ']q', '<Cmd>cnext<CR>')
  vim.keymap.set('n', '[q', '<Cmd>cprevious<CR>')
  vim.keymap.set('n', '<A-,>', '<Cmd>edit $MYVIMRC<CR>')
  -- cmdlineモードでの補完候補の選択には<Tab>を使うので<C-[pn]>は空けて良い。
  -- <Up>/<Down>はカーソル前の入力をリスペクトするのでそちらを使う。
  vim.keymap.set('c', '<C-p>', '<Up>')
  vim.keymap.set('c', '<C-n>', '<Down>')
  vim.keymap.set({ 'n', 'x' }, '<Space>y', '"+y')
  vim.keymap.set({ 'n', 'x' }, '<Space>p', '"+p')

  for _, key in ipairs { 'i', 'a' } do
    vim.keymap.set('n', key, function()
      if #fn.getline(fn.line '.') == 0 then
        return '"_cc'
      else
        return key
      end
    end, { expr = true, desc = '空の行ではインデントする' })
  end

  local gid = vim.api.nvim_create_augroup('config-lsp', { clear = false })
  vim.api.nvim_create_autocmd('LspAttach', {
    group = gid,
    callback = function(ctx)
      local opts = { buffer = ctx.buf }
      vim.keymap.set('n', 'ma', '<Cmd>FzfLua lsp_code_actions<CR>', opts)
      vim.keymap.set('n', 'mr', '<Cmd>lua vim.lsp.buf.rename()<CR>', opts)
      vim.keymap.set('n', 'gr', '<Cmd>FzfLua lsp_references<CR>', opts)
      vim.keymap.set('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
      vim.keymap.set('n', ']d', '<Cmd>lua vim.diagnostic.goto_next()<CR>', opts)
      vim.keymap.set('n', '[d', '<Cmd>lua vim.diagnostic.goto_prev()<CR>', opts)

      vim.api.nvim_create_autocmd('BufWritePre', {
        group = gid,
        buffer = ctx.buf,
        callback = function()
          vim.lsp.buf.format {
            bufnr = ctx.buf,
          }
        end,
      })
    end,
  })
end

vim.opt.helplang = { 'ja', 'en' }
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.wrap = false
vim.opt.exrc = true
vim.opt.cursorline = true
vim.opt.fileencodings = { 'utf-8', 'cp932', 'euc-jp', 'latin1' }
vim.opt.grepprg = 'rg --vimgrep'

-- vim:ft=lua et ts=2 sw=2
