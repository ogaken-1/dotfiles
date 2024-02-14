-- lua_source {{{

-- masonでインストールを管理してないLSの設定など

if vim.env.NO_LSP then
  return
end

local ok, ddc_lsp = pcall(require, 'ddc_nvim_lsp_setup')
if ok then
  ddc_lsp.setup {}
end

local lspconfig = require 'lspconfig'

if 1 == vim.fn.executable 'haskell-language-server-wrapper' then
  lspconfig.hls.setup {
    filetypes = { 'haskell' },
  }
end

if 1 == vim.fn.executable 'deno' then
  vim.g.markdown_fenced_languages = {
    'ts=typescript',
  }
  lspconfig.denols.setup {
    root_dir = function(startpath)
      local node_modules = vim.fs.find({ 'node_modules', 'tsconfig.json', 'jsconfig.json' }, {
        path = startpath,
        upward = true,
        type = 'directory',
      })
      if #node_modules > 0 then
        return
      end
      local root = vim.fs.find({ '.git', 'deno.json', 'package.json', 'deps.ts' }, {
        path = startpath,
        upward = true,
      })
      if #root == 0 then
        return vim.fs.dirname(startpath)
      end
      return vim.fs.dirname(root[1])
    end,
    init_options = {
      unstable = true,
    },
  }
end
-- }}}
