return {
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
  root_markers = { '*.sln', '*.slnx', '*.csproj', '*.vbproj' },
}
