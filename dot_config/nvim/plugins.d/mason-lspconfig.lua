-- lua_source {{{

-- masonでインストールを管理してるLSの設定はここに書く

if vim.env.NO_LSP then
  return
end

require('mason-lspconfig').setup {}

local function get_completion_capabilities()
  local dein = require 'dein'
  if not dein.is_sourced 'cmp-nvim-lsp' then
    dein.source 'cmp-nvim-lsp'
  end
  return require('cmp_nvim_lsp').default_capabilities().textDocument.completion
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion = get_completion_capabilities()

local format_disabled_capabilities = vim.deepcopy(capabilities)
format_disabled_capabilities.textDocument.formatting = nil
format_disabled_capabilities.textDocument.rangeFormatting = nil
format_disabled_capabilities.textDocument.onTypeFormatting = nil

local lspconfig = require 'lspconfig'

require('mason-lspconfig').setup_handlers {
  function(server_name)
    lspconfig[server_name].setup {
      capabilities = capabilities,
    }
  end,
  ['omnisharp'] = function()
    lspconfig.omnisharp.setup {
      capabilities = format_disabled_capabilities,
      enable_editorconfig_support = true,
      enable_roslyn_analyzers = false,
      organize_imports_on_format = false,
      enable_import_completion = false,
    }
  end,
  ['vtsls'] = function()
    lspconfig.vtsls.setup {
      capabilities = capabilities,
      root_dir = require('lspconfig.util').root_pattern { 'tsconfig.json', 'jsconfig.json', 'node_modules' },
      single_file_support = false,
    }
  end,
  ['lua_ls'] = function()
    lspconfig.lua_ls.setup {
      capabilities = format_disabled_capabilities,
      settings = {
        Lua = {
          runtime = {
            version = 'LuaJIT',
          },
          diagnostics = {
            globals = { 'vim' },
          },
          workspace = {
            checkThirdParty = false,
            library = vim.api.nvim_get_runtime_file('', true),
          },
          telemetry = {
            enable = false,
          },
          completion = {
            autoRequire = false,
          },
          format = {
            enable = vim.bool_fn.executable 'stylua',
          },
        },
      },
    }
  end,
  ['rust_analyzer'] = function()
    lspconfig.rust_analyzer.setup {
      capabilities = capabilities,
      settings = {
        ['rust-analyzer'] = {
          enable = true,
        },
      },
    }
  end,
  ['yamlls'] = function()
    lspconfig.yamlls.setup {
      capabilities = capabilities,
      settings = {
        yaml = {
          keyOrdering = false,
        },
      },
    }
  end,
}
-- }}}
