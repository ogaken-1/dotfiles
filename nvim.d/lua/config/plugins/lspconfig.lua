return {
  'neovim/nvim-lspconfig',
  event = 'FileType',
  config = function()
    local lspconfig = require 'lspconfig'
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
            },
          },
        },
      },
    }
    lspconfig.omnisharp.setup {
      enable_editorconfig_support = true,
      enable_ms_build_load_projects_on_demand = false,
      enable_roslyn_analyzers = true,
      organize_imports_on_format = false,
      enable_import_completion = false,
      analyze_open_documents_only = true,
    }
  end,
}
