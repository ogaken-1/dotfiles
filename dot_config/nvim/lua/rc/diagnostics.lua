vim.keymap.set('n', ']d', function()
  vim.diagnostic.goto_next { float = true }
end)
vim.keymap.set('n', '[d', function()
  vim.diagnostic.goto_prev { float = true }
end)

vim.diagnostic.config {
  virtual_text = false,
  float = {
    border = 'single',
    title = 'diagnostics',
    header = {},
    prefix = function(diag, _, _)
      ---@type string
      local highlight
      if diag.severity == vim.diagnostic.severity.ERROR then
        highlight = 'LspDiagnosticsError'
      elseif diag.severity == vim.diagnostic.severity.WARN then
        highlight = 'LspDiagnosticsWarning'
      elseif diag.severity == vim.diagnostic.severity.INFO then
        highlight = 'LspDiagnosticsInformation'
      elseif diag.severity == vim.diagnostic.severity.HINT then
        highlight = 'LspDiagnosticsHint'
      end

      if diag.code ~= nil then
        return ('%s[%s]: '):format(diag.source, diag.code), highlight
      else
        return ('%s: '):format(diag.source), highlight
      end
    end,
    suffix = '',
    -- source = 'always',
  },
}

vim.fn.sign_define {
  {
    name = 'DiagnosticSignError',
    text = ' ',
    texthl = 'DiagnosticSignError',
  },
  {
    name = 'DiagnosticSignWarn',
    text = ' ',
    texthl = 'DiagnosticSignWarn',
  },
  {
    name = 'DiagnosticSignInfo',
    text = ' ',
    texthl = 'DiagnosticSignInfo',
  },
  {
    name = 'DiagnosticSignHint',
    text = ' ',
    texthl = 'DiagnosticSignHint',
  },
}
