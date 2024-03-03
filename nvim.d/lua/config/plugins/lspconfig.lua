local assert = require 'config.assert'
local function plugin_path(plugin_name)
  return vim.fs.joinpath(assert.string(vim.fn.stdpath 'data'), 'lazy', plugin_name, 'lua')
end
return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'Hoffs/omnisharp-extended-lsp.nvim',
    'yioneko/nvim-vtsls',
  },
  event = 'FileType',
  config = function()
    local lspconfig = require 'lspconfig'
    if 1 == vim.fn.executable 'lua-language-server' then
      lspconfig.lua_ls.setup {
        settings = {
          Lua = {
            runtime = {
              version = 'LuaJIT',
            },
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME,
                '${3rd}/luv/library',
                '${3rd}/busted/library',
                plugin_path 'nvim-insx',
              },
            },
            format = {
              enable = false,
            },
          },
        },
      }
    end
    if 1 == vim.fn.executable 'omnisharp' then
      lspconfig.omnisharp.setup {
        cmd = { 'omnisharp' },
        handlers = {
          ['textDocument/definition'] = require('omnisharp_extended').handler,
        },
        enable_editorconfig_support = true,
        enable_ms_build_load_projects_on_demand = false,
        enable_roslyn_analyzers = true,
        organize_imports_on_format = false,
        enable_import_completion = false,
        analyze_open_documents_only = true,
      }
    end
    local util = require 'lspconfig.util'
    if 1 == vim.fn.executable 'deno' then
      lspconfig.denols.setup {
        root_dir = util.root_pattern { 'deno.json' },
      }
    end
    if 1 == vim.fn.executable 'vtsls' then
      require('lspconfig.configs').vtsls = require('vtsls').lspconfig
      lspconfig.vtsls.setup {
        root_dir = util.root_pattern { 'node_modules', 'package.json' },
      }
    end
  end,
}
