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
    local util = require 'lspconfig.util'
    local configs = {
      lua_ls = {
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
      },
      omnisharp = {
        cmd = { 'OmniSharp' },
        handlers = {
          ['textDocument/definition'] = require('omnisharp_extended').handler,
        },
        settings = {
          FormattingOptions = {
            EnableEditorConfigSupport = true,
            OrganizeImports = false,
          },
          MsBuild = {
            LoadProjectsOnDemand = false,
          },
          RoslynExtensionsOptions = {
            EnableAnalyzersSupport = true,
            EnableImportCompletion = false,
            AnalyzeOpenDocumentsOnly = true,
          },
        },
      },
      denols = {
        root_dir = util.root_pattern { 'deno.json', 'deno.jsonc', 'denops' },
      },
      yamlls = {},
      jsonls = {},
      nil_ls = {},
      gopls = {},
      typst_lsp = {},
    }
    for name, config in pairs(configs) do
      lspconfig[name].setup(config)
    end
    if 1 == vim.fn.executable 'vtsls' then
      require('lspconfig.configs').vtsls = vim.tbl_deep_extend('force', require('vtsls').lspconfig, {
        default_config = {
          root_dir = util.root_pattern { 'node_modules', 'package.json' },
          single_file_support = false,
        },
      })
      lspconfig.vtsls.setup {}
    end
    if 1 == vim.fn.executable 'pnpm' then
      lspconfig.biome.setup {
        cmd = { 'pnpm', 'biome', 'lsp-proxy' },
      }
      lspconfig.tsp_server.setup {
        cmd = { 'pnpm', 'tsp-server', '--stdio' },
      }
    end
    if 1 == vim.fn.executable 'rust-analyzer' then
      lspconfig.rust_analyzer.setup {}
    end
    if 1 == vim.fn.executable 'terraform-ls' then
      lspconfig.terraformls.setup {}
    end
  end,
}
