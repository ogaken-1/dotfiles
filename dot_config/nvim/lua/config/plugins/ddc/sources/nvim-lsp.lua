return {
  name = 'lsp',
  options = {
    mark = '[LS]',
    matchers = { 'matcher_fuzzy' },
    sorters = { 'sorter_fuzzy', 'sorter_lsp-kind' },
    ignoreCase = true,
    converters = { 'converter_fuzzy', 'converter_kind_labels' },
    minAutoCompleteLength = 1,
    forceCompletionPattern = [[\.]],
    dup = 'keep',
    timeout = 500,
  },
  params = {
    lspEngine = 'nvim-lsp',
    snippetEngine = vim.fn['denops#callback#register'](function(body)
      vim.snippet.expand(body)
    end),
    enableResolveItem = false,
    enableAdditionalTextEdit = false,
    confirmBehavior = 'replace',
  },
}
