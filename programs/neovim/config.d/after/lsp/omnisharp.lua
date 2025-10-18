return {
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
  root_dir = function(bufnr, on_dir)
    local util = require 'lspconfig.util'
    local fname = vim.api.nvim_buf_get_name(bufnr)
    on_dir(
      util.root_pattern '*.sln'(fname)
        or util.root_pattern '*.slnx'(fname)
        or util.root_pattern 'omnisharp.json'(fname)
        or util.root_pattern '*.csproj'(fname)
    )
  end,
}
