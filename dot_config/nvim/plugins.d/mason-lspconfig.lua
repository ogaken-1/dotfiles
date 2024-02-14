-- lua_source {{{

-- masonでインストールを管理してるLSの設定はここに書く

if vim.env.NO_LSP then
  return
end

require('mason-lspconfig').setup {}

local lspconfig = require 'lspconfig'

require('mason-lspconfig').setup_handlers {
  function(server_name)
    lspconfig[server_name].setup {}
  end,
  ['omnisharp'] = function()
    lspconfig.omnisharp.setup {
      handlers = {
        ['textDocument/definition'] = require('omnisharp_extended').handler,
      },
      enable_editorconfig_support = true,
      enable_roslyn_analyzers = false,
      organize_imports_on_format = false,
      enable_import_completion = false,
      analyze_open_documents_only = true,
      root_dir = require('lspconfig.util').root_pattern { '*.sln', '*.csproj' },
    }
  end,
  ['vtsls'] = function()
    lspconfig.vtsls.setup {
      root_dir = require('lspconfig.util').root_pattern { 'tsconfig.json', 'jsconfig.json', 'node_modules' },
      single_file_support = false,
    }
  end,
  ['lua_ls'] = function()
    lspconfig.lua_ls.setup {
      settings = {
        Lua = {
          runtime = {
            version = 'LuaJIT',
          },
          workspace = {
            checkThirdParty = 'Disable',
            library = {
              vim.fs.joinpath(vim.env.VIMRUNTIME, 'lua'),
              '${3rd}/luv',
              '${3rd}/busted',
            },
          },
          telemetry = {
            enable = false,
          },
          completion = {
            autoRequire = false,
            showWord = 'Disable',
          },
          format = {
            enable = false,
            defaultConfig = {
              indent_style = 'space',
              indent_size = '2',
              quote_style = 'single',
              call_arg_parentheses = 'remove',
            },
          },
        },
      },
    }
  end,
  ['rust_analyzer'] = function()
    lspconfig.rust_analyzer.setup {
      settings = {
        ['rust-analyzer'] = {
          enable = true,
        },
      },
    }
  end,
  ['yamlls'] = function()
    lspconfig.yamlls.setup {
      settings = {
        yaml = {
          keyOrdering = false,
        },
      },
    }
  end,
}
-- }}}
