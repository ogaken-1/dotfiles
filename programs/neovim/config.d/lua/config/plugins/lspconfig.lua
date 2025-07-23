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
    require('lspconfig.configs').vtsls = vim.tbl_deep_extend('force', require('vtsls').lspconfig, {
      default_config = {
        root_dir = util.root_pattern { 'node_modules', 'package.json' },
        single_file_support = false,
      },
    })
    local configs = {
      lua_ls = {
        ---@param client vim.lsp.Client
        ---@return nil
        on_init = function(client)
          if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if
              path ~= vim.fn.stdpath 'config'
              and (
                vim.loop.fs_stat(vim.fs.joinpath(path, '.luarc.json'))
                or vim.loop.fs_stat(vim.fs.joinpath(path, '.luarc.jsonc'))
              )
            then
              return
            end
          end
          client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
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
                plugin_path 'snacks.nvim',
              },
              ignoreDir = {
                '**/.direnv',
              },
            },
            format = {
              enable = false,
            },
          })
        end,
        settings = {
          Lua = {},
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
        root_dir = util.root_pattern { '*.sln', '*.slnx', '*.csproj', '*.vbproj' },
      },
      denols = {
        root_dir = util.root_pattern { 'deno.json', 'deno.jsonc', 'denops' },
      },
      yamlls = {},
      jsonls = {},
      nixd = {},
      gopls = {},
      tinymist = {},
      rust_analyzer = {},
      vtsls = {},
      gitlab_ci_ls = {},
    }
    for name, config in pairs(configs) do
      lspconfig[name].setup(config)
    end
    if 1 == vim.fn.executable 'biome' then
      lspconfig.biome.setup {}
    end
    if 1 == vim.fn.executable 'pnpm' then
      lspconfig.tsp_server.setup {
        cmd = { 'pnpm', 'tsp-server', '--stdio' },
      }
    end
    if 1 == vim.fn.executable 'terraform-ls' then
      lspconfig.terraformls.setup {}
    end
  end,
}
